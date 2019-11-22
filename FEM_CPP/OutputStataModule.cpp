#include "OutputStataModule.h"
#include "Logger.h"
#include <sstream>
#include <fstream>
#include "utility.h"
#include <stdio.h>
#include <string.h>
#include "fem_exception.h"
OutputStataModule::OutputStataModule(IVariableProvider *vp, std::vector<std::string> var_names) : AbstractOutputModule(vp, var_names)
{
	prepStataDescriptors();
	prepStataVarLabels();


}

OutputStataModule::OutputStataModule(IVariableProvider *vp) : AbstractOutputModule(vp)
{
	prepStataDescriptors();
	prepStataVarLabels();
	
}

OutputStataModule::~OutputStataModule(void)
{
}

char OutputStataModule::getStataTypeCode(VarTypes::VarTypes_t t) {
  switch(t) {
  case VarTypes::Boolean:
    return (char) 0xfb;
  case VarTypes::Short:
    return (char) 0xfc;
  case VarTypes::Long:
    return (char) 0xfd;
  case VarTypes::Float:
    return (char) 0xfe;
  case VarTypes::Double:
    return (char) 0xff;
  default:
    throw fem_exception("Unknown VarTypes_t in getStataTypeCode");
  }			
}

size_t OutputStataModule::getStataNumBytes(VarTypes::VarTypes_t t) {
  switch(t) {
  case VarTypes::Boolean:
    return 1;
  case VarTypes::Short:
    return 2;
  case VarTypes::Long:
    return 4;
  case VarTypes::Float:
    return 4;
  case VarTypes::Double:
    return 8;
  default:
    throw fem_exception("Uknown VarTypes_t in getStataNumBytes");
  }
}

void OutputStataModule::prepStataVarLabels() {

	memset(var_labels, 0, MAX_VARLABELS);
	size_t nvars = vars.size();

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
	for(size_t i = 0; i < nvars; i++)
		strncpy(var_labels + i*81, vars[i]->description().c_str(), 80);
}

void OutputStataModule::prepStataDescriptors() {

	size_t nvars = vars.size();
	char* cur_desc = descriptor;
	memset(descriptor, 0, MAX_DESCRIPTOR);

	/* Prep Stata Descriptors
	5.2  Descriptors

	The Descriptors are defined as

	Contents            Length    Format       Comments
	-----------------------------------------------------------------------------------------------------------------------------------------------
	typlist               nvar    byte array
	varlist            33*nvar    char array
	srtlist          2*(nvar+1)   int array    encoded per byteorder
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
	for(size_t i = 0; i < nvars; i++)
		memset(cur_desc + i, getStataTypeCode(vars[i]->type()), 1);
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
	for(size_t i = 0; i < nvars; i++) {
		if(vars[i]->name() == "_cons")
			strcpy(cur_desc + i*33, "Constant");
		else
			strcpy(cur_desc + i*33, vars[i]->name().c_str());
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
	short hhidpn_index = 0;
	for(size_t i = 0; i < nvars; i++)
		if(vars[i]->name() == "hhidpn")
			hhidpn_index = i+1;
	memcpy(cur_desc, (char*)&hhidpn_index, 2);
	cur_desc += 2*(nvars+1);	
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
	for(size_t i = 0; i < nvars; i++)
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


void OutputStataModule::process(PersonVector& persons, unsigned int year, Random* random) {

	Logger::log("Running Stata Output Module", FINE);
	std::ostringstream ss;
	ss << scenario->OutputDir() << _PATH_DELIM_ <<scenario->Name() << _PATH_DELIM_ <<  "detailed_output" << _PATH_DELIM_ << "y" << year << "_rep" << random->rep()+1 << ".dta";

	std::ofstream outf(ss.str().c_str(), std::ios_base::binary);
	if( outf.bad() || outf.fail())
	  throw fem_exception("Could not open file "+std::string(ss.str()));

	ss.str("");
	memset(buf, 0, BUF_SIZE);

	int nobs = 0;
	for(PersonVector::iterator itr = persons.begin(); itr != persons.end(); itr++)
	  nobs += ( (*itr)->test(Vars::active) && (*itr)->test(Vars::l2died)==0);

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
	short nvars = vars.size(); memcpy(buf+4, (char*)&nvars, 2); /*
	nobs (number of obs)     4    int       encoded per byteorder */
	memcpy(buf+6, (char*)&nobs, 4); /*
	data_label              81    char      dataset label, \0 terminated */
	ss << scenario->Name() << " " << year; 
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

	std::vector<IVariable*>::iterator vit;

	int obs_len = 0;
	for(size_t i = 0; i < (size_t) nvars; i++) {
	  obs_len += getStataNumBytes(vars[i]->type());
	}

	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
	  if( !(*itr)->test(Vars::active) || (*itr)->test(Vars::l2died) ) continue;
		memset(buf, 0, BUF_SIZE);
		char* cur_buf = buf;
		char c;
		short s;
		long l;
		float f;
		double d;
		size_t len;
		for(size_t i = 0; i < (size_t) nvars; i++) {
		  len = getStataNumBytes(vars[i]->type());
			switch(vars[i]->type()) {
				case VarTypes::Boolean:
					c =  vars[i]->is_missing(*itr) ? STATA_BYTE_MISSING : (char)vars[i]->value(*itr);
					memcpy(cur_buf, &c, len);
					cur_buf += len;
					break;
				case VarTypes::Short:
					s = vars[i]->is_missing(*itr) ? STATA_INT_MISSING: (short)vars[i]->value(*itr);
					memcpy(cur_buf, (char*)&s, len);
					cur_buf += len;
					break;
			case VarTypes::Long:
			  l = vars[i]->is_missing(*itr) ? STATA_LONG_MISSING: (long) vars[i]->value(*itr);
			  memcpy(cur_buf, (char*) &l, len);
			  cur_buf += len;
			  break;
			case VarTypes::Float:
			  f = vars[i]->is_missing(*itr) ? STATA_FLOAT_MISSING: (float) vars[i]->value(*itr);
			  memcpy(cur_buf, (char*) &f, len);
			  cur_buf += len;
			  break;
			case VarTypes::Double:
					d = vars[i]->is_missing(*itr) ? STATA_DOUBLE_MISSING : vars[i]->value(*itr);
					memcpy(cur_buf, (char*)&d, len);
					cur_buf += len;
					break;
			default:
			  throw fem_exception("Unknown VarTypes_t in OutputStataModule::process");
			}		
		}
		outf.write(buf, obs_len);
	}
	outf.close();

	ss.str("");
	ss <<  " output file: " << scenario->OutputDir() << _PATH_DELIM_ << scenario->Name() << _PATH_DELIM_ <<  "detailed_output" << _PATH_DELIM_ <<  "y" << year << "_rep" << random->rep() +1<< ".dta";
	Logger::log(ss.str(), FINE);
}
