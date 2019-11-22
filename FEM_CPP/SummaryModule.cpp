#include "SummaryModule.h"
#include "utility.h"
#include "EquationParser.h"
#include "Variable.h"
#include "Logger.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include "fem_exception.h"
#include <cstring>

const double SummaryModule::MISSING_VAL = 8.9885e+307;

SummaryModule::SummaryModule(const char* file, NodeBuilder* builder, IVariableProvider* vp) {
	nreps = 0;

	std::ifstream istrm(file);
	if( istrm.bad() || istrm.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	std::string line;
	char buffer[5000];
	while(!istrm.eof()) {
		// Read a line
		istrm.getline(buffer, 5000);

		// Check if its a valid, non comment, line
		if(strlen(buffer) > 0 && buffer[0] != '|') {
			std::vector<std::string> parts;
			// Trim off any potential extra whitespaces or carriage returns
			std::string str(buffer);
			trim(str);

			// Split by commas
			str_tokenize(str, parts, ",");

			// Trim off any whitespaces
			for(unsigned int i = 0; i < parts.size(); i++)
				trim(parts[i]);

			if(parts[0].size() > 32) {
				Logger::log("Stata might not accept summary measure name with more than 32 characters: " + parts[0],WARNING);
			}

			// Create a new summary measure based on the definition
			/** \bug If the parts vector doesn't have enough parts, this causes a segfault */
			addMeasure( new SummaryMeasure(
				vp->get(parts[2]), 
				EquationParser::parseString(parts[6], builder), 
				parts[0], 
				parts[1], 
				atof(parts[4].c_str()), 
				EquationParser::parseString(parts[5], builder), 
				parts[3]));
		}
	}

	istrm.close();
	if(numMeasures() > MAX_VARS)
	  throw fem_exception("Summary Module tried to create more than MAX_VARS measures (remember, each measure also has a sigma)\n\t\tYou can adjust SummaryModule::MAX_VARS upwards and recompile without fear of breaking anything (just consuming more memory)");
}

void SummaryModule::addMeasure(SummaryMeasure* sm) {
  if(measures.count(sm->getName()) == 0)
    measures[sm->getName()] = sm;
  else
    throw fem_exception("Summary output already has a measure named " + sm->getName());
}

void SummaryModule::setScenario(Scenario* scen) {
	nreps = scen->NReps();
	Module::setScenario(scen);

	// Clear out any data stored for a previous scenario
	for(unsigned int i = 0; i < year_measure_val_vec.size(); i++)
		delete year_measure_val_vec[i];
	year_measure_val_vec.clear();
	year_measure_mean.clear();

	year_measure_val_vec.reserve(scenario->NReps());
	for(unsigned int i = 0; i <scenario->NReps(); i++)
		year_measure_val_vec.push_back(new std::map<unsigned int, std::map<std::string, double> >());
	
	
}

SummaryModule::~SummaryModule(void)
{
  std::map<std::string,SummaryMeasure*>::iterator sum_itr;
	for(sum_itr = measures.begin(); sum_itr != measures.end(); sum_itr++)
	  delete sum_itr->second;
	for(unsigned int i = 0; i < year_measure_val_vec.size(); i++)
		delete year_measure_val_vec[i];

}


void SummaryModule::process(PersonVector& persons, unsigned int year, Random* random) {
	Logger::log("Running Summary Module", FINE);
	std::map<std::string, SummaryMeasure*>::iterator sum_itr;
	for(sum_itr = measures.begin(); sum_itr != measures.end(); sum_itr++)
		(*year_measure_val_vec[random->rep()])[year][sum_itr->second->getName()] = sum_itr->second->calculate(persons);
}

double SummaryModule::getValue(unsigned int year, std::string name, Random* random) const {
  std::map<unsigned int, std::map<std::string, double> >* tempMap = year_measure_val_vec[random->rep()];
  if (tempMap->count(year) == 0) {
    char temp[5];
    sprintf(temp, "%d", year);
    throw missing_var_exception("Summary Module has no data for year " + std::string(temp) + " when asking for " + name, "year");
  }
  if( (*year_measure_val_vec[random->rep()])[year].count(name) == 0)
    throw missing_var_exception("Summary Module cannot return value for " + name, name);
  return (*year_measure_val_vec[random->rep()])[year][name];
}

void SummaryModule::output() {
	prepStataVarLabels();
	prepStataDescriptors();
	// Write stata output
	std::ostringstream ss;
	ss << scenario->OutputDir() << _PATH_DELIM_ << scenario->Name() << _PATH_DELIM_ << scenario->Name() << "_summary.dta";
	std::string ofile_name(ss.str());

	std::ofstream outf(ofile_name.c_str(), std::ios_base::binary);
	if( outf.bad() || outf.fail())
	  throw fem_exception("Could not open file "+ofile_name);

	ss.str("");
	memset(buf, 0, BUF_SIZE);

	/* Write Stata Header

	The Header is defined as

	Contents            Length    Format    Comments
	-----------------------------------------------------------------------------------------------------------------------------------------------
	ds_format                1    byte      contains 114 = 0x72	*/
	buf[0] = 0x72;	/*
	byteorder                1    byte      0x01 -> HILO, 0x02 -> LOHI	*/ 
	// Determine byte order
	unsigned int a=1;
	if(0 != *((unsigned char *)(&a)))
		buf[1] = 0x02;
	else 
		buf[1] = 0x01; 
	/*
	filetype                 1    byte      0x01	*/
	buf[2] = 0x01; 	/*
	unused                   1    byte      0x01	*/
	buf[3] = 0x01; 	/*
	nvar (number of vars)    2    int       encoded per byteorder */
	short nvars = numMeasures() + 1; memcpy(buf+4, (char*)&nvars, 2); /*
	nobs (number of obs)     4    int       encoded per byteorder */
	int nobs = year_measure_mean.size(); memcpy(buf+6, (char*)&nobs, 4); /*
	data_label              81    char      dataset label, \0 terminated */
	ss << scenario->Name() << " summary"; 
	strncpy(buf+10, ss.str().c_str(), strlen(ss.str().c_str())); /*
	time_stamp              18    char      date/time saved, \0 terminated
	-----------------------------------------------------------------------------------------------------------------------------------------------
	Total                  109 */
	outf.write(buf, 109); /*

	time_stamp[17] must be set to binary zero.  When writing a dataset, you may record the time stamp as blank time_stamp[0]=\0), but you must still
	set time_stamp[17] to binary zero as well.  If you choose to write a time stamp, its format is

	dd Mon yyyy hh:mm

	dd and hh may be written with or without leading zeros, but if leading zeros are suppressed, a blank must be substituted in their place.
	*/
	memset(buf, 0, BUF_SIZE);

	/* Write Stata Descriptors */
	outf.write(descriptor, 118*nvars + 2);

	/* Write Variable Labels */
	outf.write(var_labels, 81*nvars);

	/* Write expansion fields
	5.4  Expansion fields

	The Expansion Fields are recorded as

	Contents            Length    Format     Comments
	--------------------------------------------------------------------
	data type                1    byte       coded, only 0 and 1 defined
	len                      4    int        encoded per byteorder
	contents               len    varies

	data type                1    byte       coded, only 0 and 1 defined
	len                      4    int        encoded per byteorder
	contents               len    varies

	data type                1    byte       code 0 means end
	len                      4    int        0 means end
	--------------------------------------------------------------------

	Expansion fields conclude with code 0 and len 0; before the termination marker, there may be no or many separate data blocks.  Expansion fields
	are used to record information that is unique to Stata and has no equivalent in other data management packages.  Expansion fields are always
	optional when writing data and, generally, programs reading Stata datasets will want to ignore the expansion fields.  The format makes this easy.
	When writing, write 5 bytes of zeros for this field.  When reading, read five bytes; the last four bytes now tell you the size of the next read,
	which you discard.  You then continue like this until you read 5 bytes of zeros.

	The only expansion fields currently defined are type 1 records for variable's characteristics.  The design, however, allows new types of
	expansion fields to be included in subsequent releases of Stata without changes in the data format since unknown expansion types can simply be
	skipped.

	For those who care, the format of type 1 records is a binary-zero terminated variable name in bytes 0-32, a binary-zero terminated characteristic
	name in bytes 33-65, and a binary-zero terminated string defining the contents in bytes 66 through the end of the record.
	*/
	outf.write(buf, 5);

	/* Write the data 
	5.5  Data

	The Data are recorded as

	Contents                  Length         Format
	-----------------------------------------------
	obs 1, var 1         per typlist    per typlist
	obs 1, var 2         per typlist    per typlist
	...
	obs 1, var nvar      per typlist    per typlist

	obs 2, var 1         per typlist    per typlist
	obs 2, var 2         per typlist    per typlist
	...
	obs 2, var nvar      per typlist    per typlist
	.
	.
	obs nobs, var 1      per typlist    per typlist
	obs nobs, var 2      per typlist    per typlist
	...
	obs nobs, var nvar   per typlist    per typlist
	-----------------------------------------------

	The data are written as all the variables on the first observation, followed by all the data on the second observation, and so on.  Each variable
	is written in its own internal format, as given in typlist.  All values are written per byteorder.  Strings are null terminated if they are
	shorter than the allowed space, but they are not terminated if they occupy the full width.

	End-of-file may occur at this point.  If it does, there are no value labels to be read.  End-of-file may similarly occur between value labels.
	On end-of-file, all data have been processed. */
	int	obs_len = 2; // year is first
	for(int i = 0; i < nvars-1; i++) {
		obs_len += 8; // all are double
	}

	std::vector<unsigned int> years;
	for(std::map<unsigned int, std::map<std::string, double> >::iterator itr = year_measure_mean.begin(); itr != year_measure_mean.end(); itr++)
		years.push_back((*itr).first);
	std::sort(years.begin(), years.end());

	for(unsigned int i = 0; i < years.size(); i++) {
		memset(buf, 0, BUF_SIZE);
		char* cur_buf = buf;
		short s = years[i];
		memcpy(cur_buf, (char*)&s, 2);
		cur_buf += 2;
		// Write means and sigmas in one loop for efficiency
		std::map<std::string, SummaryMeasure*>::const_iterator summ;
		double v=0;
		for(summ = measures.begin(); summ != measures.end(); summ++) { 
			v = year_measure_mean[years[i]][summ->second->getName()];
			memcpy(cur_buf, (char*)&v, 8);
			cur_buf += 8;
		}
		outf.write(buf, obs_len);
	}

	ss <<  " output file: "  << ofile_name;
	Logger::log(ss.str(), FINE);
	
}

void SummaryModule::outputByRep()
{
	prepStataVarLabelsByRep();
	prepStataDescriptorsByRep();
	// Write stata output
	std::ostringstream ss;
	ss << scenario->OutputDir() << _PATH_DELIM_ << scenario->Name() << _PATH_DELIM_ << scenario->Name() << "_by_rep.dta";
	std::string ofile_name(ss.str());

	std::ofstream outf(ofile_name.c_str(), std::ios_base::binary);
	if( outf.bad() || outf.fail())
	  throw fem_exception("Could not open file "+std::string(ss.str()));

	ss.str("");
	memset(buf, 0, BUF_SIZE);

	/* Write Stata Header

	The Header is defined as

	Contents            Length    Format    Comments
	-----------------------------------------------------------------------------------------------------------------------------------------------
	ds_format                1    byte      contains 114 = 0x72	*/
	buf[0] = 0x72;	/*
	byteorder                1    byte      0x01 -> HILO, 0x02 -> LOHI	*/ 
	// Determine byte order
	unsigned int a=1;
	if(0 != *((unsigned char *)(&a)))
		buf[1] = 0x02;
	else 
		buf[1] = 0x01; 
	/*
	filetype                 1    byte      0x01	*/
	buf[2] = 0x01; 	/*
	unused                   1    byte      0x01	*/
	buf[3] = 0x01; 	/*
	nvar (number of vars)    2    int       encoded per byteorder */
	short nvars = numMeasures() + 2; memcpy(buf+4, (char*)&nvars, 2); /*
	nobs (number of obs)     4    int       encoded per byteorder */
	int nobs = nreps*year_measure_val_vec[0]->size(); memcpy(buf+6, (char*)&nobs, 4); /*
	data_label              81    char      dataset label, \0 terminated */
	ss << scenario->Name() << " summary"; 
	strncpy(buf+10, ss.str().c_str(), strlen(ss.str().c_str())); /*
	time_stamp              18    char      date/time saved, \0 terminated
	-----------------------------------------------------------------------------------------------------------------------------------------------
	Total                  109 */
	outf.write(buf, 109); /*

	time_stamp[17] must be set to binary zero.  When writing a dataset, you may record the time stamp as blank time_stamp[0]=\0), but you must still
	set time_stamp[17] to binary zero as well.  If you choose to write a time stamp, its format is

	dd Mon yyyy hh:mm

	dd and hh may be written with or without leading zeros, but if leading zeros are suppressed, a blank must be substituted in their place.
	*/
	memset(buf, 0, BUF_SIZE);

	/* Write Stata Descriptors */
	outf.write(descriptor, 118*nvars + 2);

	/* Write Variable Labels */
	outf.write(var_labels, 81*nvars);

	/* Write expansion fields
	5.4  Expansion fields

	The Expansion Fields are recorded as

	Contents            Length    Format     Comments
	--------------------------------------------------------------------
	data type                1    byte       coded, only 0 and 1 defined
	len                      4    int        encoded per byteorder
	contents               len    varies

	data type                1    byte       coded, only 0 and 1 defined
	len                      4    int        encoded per byteorder
	contents               len    varies

	data type                1    byte       code 0 means end
	len                      4    int        0 means end
	--------------------------------------------------------------------

	Expansion fields conclude with code 0 and len 0; before the termination marker, there may be no or many separate data blocks.  Expansion fields
	are used to record information that is unique to Stata and has no equivalent in other data management packages.  Expansion fields are always
	optional when writing data and, generally, programs reading Stata datasets will want to ignore the expansion fields.  The format makes this easy.
	When writing, write 5 bytes of zeros for this field.  When reading, read five bytes; the last four bytes now tell you the size of the next read,
	which you discard.  You then continue like this until you read 5 bytes of zeros.

	The only expansion fields currently defined are type 1 records for variable's characteristics.  The design, however, allows new types of
	expansion fields to be included in subsequent releases of Stata without changes in the data format since unknown expansion types can simply be
	skipped.

	For those who care, the format of type 1 records is a binary-zero terminated variable name in bytes 0-32, a binary-zero terminated characteristic
	name in bytes 33-65, and a binary-zero terminated string defining the contents in bytes 66 through the end of the record.
	*/
	outf.write(buf, 5);

	/* Write the data 
	5.5  Data

	The Data are recorded as

	Contents                  Length         Format
	-----------------------------------------------
	obs 1, var 1         per typlist    per typlist
	obs 1, var 2         per typlist    per typlist
	...
	obs 1, var nvar      per typlist    per typlist

	obs 2, var 1         per typlist    per typlist
	obs 2, var 2         per typlist    per typlist
	...
	obs 2, var nvar      per typlist    per typlist
	.
	.
	obs nobs, var 1      per typlist    per typlist
	obs nobs, var 2      per typlist    per typlist
	...
	obs nobs, var nvar   per typlist    per typlist
	-----------------------------------------------

	The data are written as all the variables on the first observation, followed by all the data on the second observation, and so on.  Each variable
	is written in its own internal format, as given in typlist.  All values are written per byteorder.  Strings are null terminated if they are
	shorter than the allowed space, but they are not terminated if they occupy the full width.

	End-of-file may occur at this point.  If it does, there are no value labels to be read.  End-of-file may similarly occur between value labels.
	On end-of-file, all data have been processed. */
	int	obs_len = 2; // year is first
	obs_len += 2; // rep is second
	obs_len += 8 * numMeasures();

	for(size_t r = 0; r < nreps; r++) {
		std::vector<unsigned int> years;
		for(std::map<unsigned int, std::map<std::string, double> >::iterator itr = year_measure_val_vec[r]->begin(); itr != year_measure_val_vec[r]->end(); itr++)
			years.push_back((*itr).first);
		std::sort(years.begin(), years.end());

		for(unsigned int i = 0; i < years.size(); i++) {
			memset(buf, 0, BUF_SIZE);
			char* cur_buf = buf;
			// write year
			short s = years[i];
			memcpy(cur_buf, (char*)&s, 2);
			cur_buf += 2;
			// write rep
			memcpy(cur_buf, (char*)&r, 2);
			cur_buf += 2;
			std::map<std::string, SummaryMeasure*>::const_iterator summ;
			for(summ = measures.begin(); summ != measures.end(); summ++) {
				double d = (*year_measure_val_vec[r])[years[i]][summ->first];
				memcpy(cur_buf, (char*)&d, 8);
				cur_buf += 8;
			}
			outf.write(buf, obs_len);
		}
	}

	ss <<  " output file: "  << ofile_name;
	Logger::log(ss.str(), FINE);
	
}






void SummaryModule::prepStataVarLabels() {

	memset(var_labels, 0, MAX_VARLABELS);

	/* Prep Variable Labels
	5.3  Variable labels

	The Variable Labels are recorded as

	Contents            Length    Format     Comments
	------------------------------------------------------
	Variable 1's label      81    char       \0 terminated
	Variable 2's label      81    char       \0 terminated
	...
	Variable nvar's label   81    char       \0 terminated
	------------------------------------------------------
	Total              81*nvar

	If a variable has no label, the first character of its label is \0.
	*/
	memcpy(var_labels, "year", strlen("year"));
	std::map<std::string, SummaryMeasure*>::const_iterator summ;
	unsigned int i = 0;
	for(summ = measures.begin(); summ != measures.end(); summ++) {
	  strncpy(var_labels + (i+1)*81, summ->second->getDesc().c_str(), 80);
	  i++;
	}
}

void SummaryModule::prepStataVarLabelsByRep() {

	memset(var_labels, 0, MAX_VARLABELS);

	/* Prep Variable Labels
	5.3  Variable labels

	The Variable Labels are recorded as

	Contents            Length    Format     Comments
	------------------------------------------------------
	Variable 1's label      81    char       \0 terminated
	Variable 2's label      81    char       \0 terminated
	...
	Variable nvar's label   81    char       \0 terminated
	------------------------------------------------------
	Total              81*nvar

	If a variable has no label, the first character of its label is \0.
	*/
	memcpy(var_labels, "year", strlen("year"));
	memcpy(var_labels+81, "rep", strlen("rep"));
	std::map<std::string, SummaryMeasure*>::const_iterator summ;
	unsigned int i = 0;
	for(summ = measures.begin(); summ != measures.end(); summ++) {
	  strncpy(var_labels + (i+2)*81, summ->second->getDesc().c_str(), 80);
	  i++;
	}
}

void SummaryModule::prepStataDescriptors() {

	short nvars = numMeasures();
	char* cur_desc = descriptor;
	memset(descriptor, 0, MAX_DESCRIPTOR);

	/* Prep Stata Descriptors
	5.2  Descriptors

	The Descriptors are defined as

	Contents            Length    Format       Comments
	-----------------------------------------------------------------------------------------------------------------------------------------------
	typlist               nvar    byte array
	varlist            33*nvar    char array
	srtlist            (nvar+1)   int array    encoded per byteorder
	fmtlist            49*nvar    char array
	lbllist            33*nvar    char array
	-----------------------------------------------------------------------------------------------------------------------------------------------


	typlist stores the type of each variable, 1, ..., nvar.  The types are encoded:

	type          code
	--------------------
	str1        1 = 0x01
	str2        2 = 0x02
	...
	str244    244 = 0xf4
	byte      251 = 0xfb  (sic)
	int       252 = 0xfc
	long      253 = 0xfd
	float     254 = 0xfe
	double    255 = 0xff
	--------------------

	Stata stores five numeric types:  double, float, long, int, and byte.  If nvar==4, a typlist of 0xfcfffdfe indicates that variable 1 is an int,
	variable 2 a double, variable 3 a long, and variable 4 a float.  Types above 0x01 through 0xf4 are used to represent strings.  For example, a
	string with maximum length 8 would have type 0x08.  If typlist is read into the C-array char typlist[], then typlist[i-1] indicates the type of
	variable i. */
	memset(cur_desc, 0xfc, 1);
	cur_desc += 1;
	for(int i = 0; i < nvars; i++)
		memset(cur_desc + i, 0xff, 1);
	cur_desc += nvars;
	/*
	varlist contains the names of the Stata variables 1, ..., nvar, each up to 32 characters in length, and each terminated by a binary zero (\0).
	For instance, if nvar==4,

	0       33        66          99
	|        |         |           |
	vbl1\0...myvar\0...thisvar\0...lstvar\0...


	would indicate that variable 1 is named vbl1, variable 2 myvar, variable 3 thisvar, and variable 4 lstvar.  The byte positions indicated by
	periods will contain random numbers (and note that we have omitted some of the periods).  If varlist is read into the C-array char varlist[],
	then &varlist[(i-1)*33] points to the name of the ith variable. */
	strcpy(cur_desc, "year");
	cur_desc += 33;
	std::map<std::string, SummaryMeasure*>::const_iterator summ;
	unsigned int i = 0;
	for(summ = measures.begin(); summ != measures.end(); summ++) {
	  strcpy(cur_desc + i*33, summ->first.c_str());
	  i++;
	}
	cur_desc += 33*nvars;
	/*
	srtlist specifies the sort-order of the dataset and is terminated by an (int) 0.  Each 2 bytes is 1 int and contains either a variable number or
	zero.  The zero marks the end of the srtlist, and the array positions after that contain random junk.  For instance, if the data are not sorted,
	the first int will contain a zero and the ints thereafter will contain junk.  If nvar==4, the record will appear as

	0000................

	If the dataset is sorted by one variable myvar and if that variable is the second variable in the varlist, the record will appear as

	00020000............  (if byteorder==HILO)
	02000000............  (if byteorder==LOHI)

	If the dataset is sorted by myvar and within myvar by vbl1, and if vbl1 is the first variable in the dataset, the record will appear as

	000200010000........  (if byteorder==HILO)
	020001000000........  (if byteorder==LOHI)


	If srtlist were read into the C-array short int srtlist[], then srtlist[0] would be the number of the first sort variable or, if the data were
	not sorted, 0.  If the number is not zero, srtlist[1] would be the number of the second sort variable or, if there is not a second sort variable,
	0, and so on. */
	short year_index = 1;
	memcpy(cur_desc, (char*)&year_index, 2);
	cur_desc += 2*(nvars+1+1);	
	/*		
	fmtlist contains the formats of the variables 1, ..., nvar.  Each format is 49 bytes long and includes a binary zero end-of-string marker.  For
	instance,

	%9.0f\0..........................................%8.2f\0......
	....................................%20.0g\0..................
	.......................%td\0..................................
	..........%tcDDmonCCYY_HH:MM:SS.sss\0......................

	indicates that variable 1 has a %9.0f format, variable 2 a %8.2f format, variable 3 a %20.0g format, and so on.  Note that these are Stata
	formats, not C formats.

	1.  Formats beginning with %t or %-t are Stata's date and time formats.

	2.  Stata has an old %d format notation and some datasets still have them.  Format %d... is equivalent to modern format %td... and %-d... is
	equivalent to %-td...

	3.  Nondate formats ending in gc or fc are similar to C's g and f formats, but with commas.  Most translation routines would ignore the
	ending c (change it to \0).

	4.  Formats may contain commas rather than period, such as %9,2f, indicating European format.

	If fmtlist is read into the C-array char fmtlist[], then &fmtlist[12*(i-1)] refers to the starting address of the format for the ith variable. */
	strcpy(cur_desc, "%12.0g");
	cur_desc += 49;
	for(int i = 0; i < nvars; i++)
		strcpy(cur_desc + i*49, "%12.0g");
	cur_desc += 49*nvars;	
	/*
	lbllist contains the names of the value formats associated with the variables 1, ..., nvar.  Each value-format name is 33 bytes long and includes
	a binary zero end-of-string marker.  For instance,

	0   33        66   99
	|    |         |    |
	\0...yesno\0...\0...yesno\0...

	indicates that variables 1 and 3 have no value label associated with them, whereas variables 2 and 4 are both associated with the value label
	named yesno.  If lbllist is read into the C-array char lbllist[], then &lbllist[33*(i-1)] points to the start of the label name associated with
	the ith variable.
	*/

}


void SummaryModule::prepStataDescriptorsByRep() {

	short nvars = numMeasures();
	char* cur_desc = descriptor;
	memset(descriptor, 0, MAX_DESCRIPTOR);

	/* Prep Stata Descriptors
	5.2  Descriptors

	The Descriptors are defined as

	Contents            Length    Format       Comments
	-----------------------------------------------------------------------------------------------------------------------------------------------
	typlist               nvar    byte array
	varlist            33*nvar    char array
	srtlist            (nvar+1)   int array    encoded per byteorder
	fmtlist            49*nvar    char array
	lbllist            33*nvar    char array
	-----------------------------------------------------------------------------------------------------------------------------------------------


	typlist stores the type of each variable, 1, ..., nvar.  The types are encoded:

	type          code
	--------------------
	str1        1 = 0x01
	str2        2 = 0x02
	...
	str244    244 = 0xf4
	byte      251 = 0xfb  (sic)
	int       252 = 0xfc
	long      253 = 0xfd
	float     254 = 0xfe
	double    255 = 0xff
	--------------------

	Stata stores five numeric types:  double, float, long, int, and byte.  If nvar==4, a typlist of 0xfcfffdfe indicates that variable 1 is an int,
	variable 2 a double, variable 3 a long, and variable 4 a float.  Types above 0x01 through 0xf4 are used to represent strings.  For example, a
	string with maximum length 8 would have type 0x08.  If typlist is read into the C-array char typlist[], then typlist[i-1] indicates the type of
	variable i. */
	memset(cur_desc, 0xfc, 1); // year
	cur_desc += 1;
	memset(cur_desc, 0xfc, 1); // rep
	cur_desc += 1;
	for(int i = 0; i < nvars; i++)
		memset(cur_desc + i, 0xff, 1);
	cur_desc += nvars;
	/*
	varlist contains the names of the Stata variables 1, ..., nvar, each up to 32 characters in length, and each terminated by a binary zero (\0).
	For instance, if nvar==4,

	0       33        66          99
	|        |         |           |
	vbl1\0...myvar\0...thisvar\0...lstvar\0...


	would indicate that variable 1 is named vbl1, variable 2 myvar, variable 3 thisvar, and variable 4 lstvar.  The byte positions indicated by
	periods will contain random numbers (and note that we have omitted some of the periods).  If varlist is read into the C-array char varlist[],
	then &varlist[(i-1)*33] points to the name of the ith variable. */
	strcpy(cur_desc, "year");
	cur_desc += 33;
	strcpy(cur_desc, "rep");
	cur_desc += 33;
	std::map<std::string, SummaryMeasure*>::const_iterator summ;
	for(summ = measures.begin(); summ != measures.end(); summ++) {
	  strcpy(cur_desc, summ->first.c_str());
	  cur_desc += 33;
	}
	/*
	srtlist specifies the sort-order of the dataset and is terminated by an (int) 0.  Each 2 bytes is 1 int and contains either a variable number or
	zero.  The zero marks the end of the srtlist, and the array positions after that contain random junk.  For instance, if the data are not sorted,
	the first int will contain a zero and the ints thereafter will contain junk.  If nvar==4, the record will appear as

	0000................

	If the dataset is sorted by one variable myvar and if that variable is the second variable in the varlist, the record will appear as

	00020000............  (if byteorder==HILO)
	02000000............  (if byteorder==LOHI)

	If the dataset is sorted by myvar and within myvar by vbl1, and if vbl1 is the first variable in the dataset, the record will appear as

	000200010000........  (if byteorder==HILO)
	020001000000........  (if byteorder==LOHI)


	If srtlist were read into the C-array short int srtlist[], then srtlist[0] would be the number of the first sort variable or, if the data were
	not sorted, 0.  If the number is not zero, srtlist[1] would be the number of the second sort variable or, if there is not a second sort variable,
	0, and so on. */
	short year_index = 1;
	short rep_index = 2;
	memcpy(cur_desc, (char*)&rep_index, 2);
	memcpy(cur_desc+2, (char*)&year_index, 2);
	cur_desc += nvars+2+1;
	/*		
	fmtlist contains the formats of the variables 1, ..., nvar.  Each format is 49 bytes long and includes a binary zero end-of-string marker.  For
	instance,

	%9.0f\0..........................................%8.2f\0......
	....................................%20.0g\0..................
	.......................%td\0..................................
	..........%tcDDmonCCYY_HH:MM:SS.sss\0......................

	indicates that variable 1 has a %9.0f format, variable 2 a %8.2f format, variable 3 a %20.0g format, and so on.  Note that these are Stata
	formats, not C formats.

	1.  Formats beginning with %t or %-t are Stata's date and time formats.

	2.  Stata has an old %d format notation and some datasets still have them.  Format %d... is equivalent to modern format %td... and %-d... is
	equivalent to %-td...

	3.  Nondate formats ending in gc or fc are similar to C's g and f formats, but with commas.  Most translation routines would ignore the
	ending c (change it to \0).

	4.  Formats may contain commas rather than period, such as %9,2f, indicating European format.

	If fmtlist is read into the C-array char fmtlist[], then &fmtlist[12*(i-1)] refers to the starting address of the format for the ith variable. */
	strcpy(cur_desc, "%12.0g");
	cur_desc += 49;
	strcpy(cur_desc, "%12.0g");
	cur_desc += 49;
	for(int i = 0; i < nvars; i++)
		strcpy(cur_desc + i*49, "%12.0g");
	cur_desc += 49*nvars;	
	/*
	lbllist contains the names of the value formats associated with the variables 1, ..., nvar.  Each value-format name is 33 bytes long and includes
	a binary zero end-of-string marker.  For instance,

	0   33        66   99
	|    |         |    |
	\0...yesno\0...\0...yesno\0...

	indicates that variables 1 and 3 have no value label associated with them, whereas variables 2 and 4 are both associated with the value label
	named yesno.  If lbllist is read into the C-array char lbllist[], then &lbllist[33*(i-1)] points to the start of the label name associated with
	the ith variable.
	*/

}


void SummaryModule::scenarioFinished() {
	// The scenario is finished. Compute the mean over all the repititions. 
	// For each measure, only use the calculated values when there was something to calculate over, so not MISSING
	
  std::map<std::string, SummaryMeasure*>::const_iterator sum_itr;

	/* Init the mean to zero */
	for(unsigned int yr = scenario->StartYr(); yr <= scenario->EndYr(); yr += scenario->YrStep()) {
		for(sum_itr = measures.begin(); sum_itr != measures.end(); sum_itr++) {
			year_measure_mean[yr][sum_itr->first] = 0;
		}
	}

	if(nreps > 0) {
		/* For each year/measure, iterate over the repititions and accumulate the value of the mean */
		for(unsigned int yr = scenario->StartYr(); yr <= scenario->EndYr(); yr += scenario->YrStep()) {
			for(sum_itr = measures.begin(); sum_itr != measures.end(); sum_itr++) {
				// Count how many were missing
				int nmissing = 0;
				for(size_t i = 0; i < nreps; i++) {
					if ((*year_measure_val_vec[i])[yr][sum_itr->first] == SummaryModule::MISSING_VAL)
						nmissing++;
					else
						year_measure_mean[yr][sum_itr->first] += (*year_measure_val_vec[i])[yr][sum_itr->first]; // accumulate
				}

				// Did we have any non missing reps?
				if(nreps > nmissing)
					year_measure_mean[yr][sum_itr->first] /= (double)(nreps-nmissing); // divide by nreps-nmissing to get the mean
				else
					year_measure_mean[yr][sum_itr->first] = SummaryModule::MISSING_VAL; // All were missing, so mean is as well
			}
		}
	}

}

	

void SummaryModule::addRepData(unsigned int rep, double* data) {
	unsigned int nmeasures = numMeasures();
	unsigned int nyr_steps = (scenario->EndYr() - scenario->StartYr())/scenario->YrStep() + 1;
	std::map<std::string, SummaryMeasure*>::const_iterator summ;
	for(unsigned int y = 0; y < nyr_steps; y++) {
	  unsigned int i = 0;
	  for(summ = measures.begin(); summ != measures.end(); summ++) {
	    (*year_measure_val_vec[rep])
	      [y*scenario->YrStep() + scenario->StartYr()]
	      [summ->first] = data[y*nmeasures + i];
	    i++;
	  }
	}
}

void SummaryModule::getRepData(unsigned int rep, double* data) const {
	unsigned int nmeasures = numMeasures();
	unsigned int nyr_steps = (scenario->EndYr() - scenario->StartYr())/scenario->YrStep() + 1;
	std::map<std::string, SummaryMeasure*>::const_iterator summ;
	for(unsigned int y = 0; y < nyr_steps; y++) {
	  unsigned int i = 0;
	  for(summ = measures.begin(); summ != measures.end(); summ++) {
	    data[y*nmeasures + i] = (*year_measure_val_vec[rep])
	      [y*scenario->YrStep() + scenario->StartYr()]
	      [summ->first];
	    i++;
	  }
	}
}

SummaryMeasure* SummaryModule::getMeasure(std::string name) {
  if(hasMeasure(name)) return measures.at(name);
  else throw missing_var_exception("SummaryModule does not contain a SummaryMeasure called " + name);
}
