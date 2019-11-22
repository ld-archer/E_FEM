#include "utility.h"
#include "fem_exception.h"
#include "file_not_found_exception.h"
#include <iostream>
#include <sstream>
#include <fstream>
#include <limits>
#include <cstring>

void str_tokenize(const std::string& str,
				  std::vector<std::string>& tokens,
				  const std::string& delimiters)
{
  if(str.length() > 0) {
    std::string value;
    std::string::size_type startPos = 0, pos = str.find_first_of(delimiters);
    while (pos != std::string::npos)
      {
	tokens.push_back(str.substr(startPos, pos - startPos));
	startPos = pos + 1;
	pos = str.find_first_of(delimiters, startPos);
      }
    tokens.push_back(str.substr(startPos, str.length() - startPos));
  }
}





void str_tokenize_keep_delim(const std::string& str,
							 std::vector<std::string>& tokens,
							 const std::string& delimiters)
{
	std::string::size_type start     = 0;

	std::string::size_type stop     = str.find_first_of(delimiters, start);

	while (std::string::npos != start)
	{

		tokens.push_back(str.substr(start, std::min(stop, str.length()) - start));

		if(str.find_first_of(delimiters, stop) < str.find_first_not_of(delimiters, stop)) {
			start     = str.find_first_of(delimiters, stop);
			stop      = std::min(str.find_first_of(delimiters, stop+1),str.find_first_not_of(delimiters, stop+1));
		} else {
			start     = str.find_first_not_of(delimiters, stop);
			stop      = str.find_first_of(delimiters, stop+1);
		}


	}
}

void str_tokenize_keep_delim(const std::string& str,
							 std::vector<std::string>& tokens,
							 std::vector<std::string>& delims)
{

	std::vector<unsigned int> cuts;



	std::string::size_type start     = 0;

	cuts.push_back(0);
	while(start < str.length()) {
		std::string::size_type max_stop = start;
		for(std::string::size_type stop = start + 1; stop <= str.length(); stop++) {
			std::string s = str.substr(start, stop-start);
			bool isdelim = false;
			for(std::vector<std::string>::iterator it = delims.begin(); it != delims.end() && !isdelim; ++it) {
				if(s == *it)
					isdelim = true;
			}
			if(isdelim)
				max_stop = stop;
		}
		if(max_stop > start) {
			if(start > cuts[cuts.size()-1]) {
				cuts.push_back(start);
			}

			cuts.push_back(max_stop);
			start = max_stop;
		} else {
			start++;
		}
	}

	if(cuts[cuts.size()-1] < str.length())
		cuts.push_back(str.length());

	for(unsigned int i = 0; i < cuts.size()-1; i++) {
		tokens.push_back(str.substr(cuts[i], cuts[i+1] - cuts[i]));
	}
}


void trim(std::string& str)
{
	// List of possible white space chars we want to remove
	std::string ws = "\r\n\t\f ";
	std::string::size_type pos = str.find_last_not_of(ws);
	if(pos != std::string::npos) {
		str.erase(pos + 1);
		pos = str.find_first_not_of(ws);
		if(pos != std::string::npos) str.erase(0, pos);
	}
	else str.erase(str.begin(), str.end());
}


#ifdef __FEM_UNIX__
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>

#include <iostream>
int getdir (std::string dir, std::vector<std::string> &files, std::string ext)
{
	DIR *dp;
	struct dirent *dirp;
	dir += "/";
	if((dp  = opendir(dir.c_str())) == NULL) {
		std::ostringstream ss;
		ss << "Error(" << errno << ") opening " << dir << std::endl;
		throw file_not_found_exception(ss.str().c_str());
	}

	while ((dirp = readdir(dp)) != NULL) {
		std::string filename(dirp->d_name);
		if(filename.length() > 3 && filename.substr(filename.length() - 3, 3) == ext.substr(ext.length() - 3, 3))
			files.push_back(std::string(dirp->d_name));
	}
	closedir(dp);
	return 0;
}


void make_dir(const std::string& dir) {
   if (mkdir(dir.c_str(), 0777) == -1) {  // Create the directory
	   	std::ostringstream ss;
		ss << "Error(" << errno << ") creating " << dir << std::endl;
		throw fem_exception(ss.str().c_str());
   }
}

   
bool dir_exists(const std::string& dir) 
{
	struct stat statBuffer;
	return (stat(dir.c_str(), &statBuffer) >= 0 && // make sure it exists
		statBuffer.st_mode & S_IFDIR); // and it's not a file
}


#endif // __FEM_UNIX__

#ifdef __FEM_WIN__
#include <windows.h>
#include <stdio.h>
#include <direct.h>
#include <tchar.h>
#include <strsafe.h>
#include <sys/stat.h>   
#include "fem_exception.h"


int getdir (std::string dir, std::vector<std::string> &files, std::string ext)
{
   WIN32_FIND_DATA ffd;

   TCHAR szDir[MAX_PATH];
   HANDLE hFind = INVALID_HANDLE_VALUE;
   DWORD dwError=0;
   // Prepare string for use with FindFile functions. 
	dir += "\\" + ext;

	    // Convert to a wchar_t*
	size_t origsize = strlen(dir.c_str()) + 1;
    size_t convertedChars = 0;
    mbstowcs_s(&convertedChars, szDir, origsize, dir.c_str(), _TRUNCATE);

   // Find the first file in the directory.

	hFind = FindFirstFile(szDir, &ffd);

   if (INVALID_HANDLE_VALUE == hFind) {
		std::ostringstream ss;
		ss << "Error opening " << dir << std::endl;
		throw file_not_found_exception(ss.str().c_str());
	}
   
   // List all the files in the directory with some info about them.

   do
   {
	   if (!(ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
		   // Convert to a char*
			size_t origsize = wcslen(ffd.cFileName) + 1;
			const size_t newsize = 100;
			size_t convertedChars = 0;
			char nstring[newsize];
		    wcstombs_s(&convertedChars, nstring, origsize, ffd.cFileName, _TRUNCATE);

		   files.push_back(std::string(nstring));
      }
   }
   while (FindNextFile(hFind, &ffd) != 0);
 
   dwError = GetLastError();
   if (dwError != ERROR_NO_MORE_FILES) {
		std::ostringstream ss;
		ss << "Error reading " << dir << std::endl;
		throw file_not_found_exception(ss.str().c_str());
	}

   FindClose(hFind);
   return 0;
}


void make_dir(const std::string& dir) {
   if (_mkdir(dir.c_str()) == -1) {  // Create the directory
	   	std::ostringstream ss;
		ss << "Error(" << errno << ") creating " << dir << std::endl;
		throw fem_exception(ss.str().c_str());
   }
}


bool dir_exists(const std::string& dir) 
{
	struct _stat statBuffer;
	return (_stat(dir.c_str(), &statBuffer) >= 0 && // make sure it exists
		statBuffer.st_mode & S_IFDIR); // and it's not a file
}


#endif // __FEM_WIN__

void copy_file(const std::string& dest, const std::string& src) {
	std::ifstream ifs(src.c_str(), std::ios::binary);
	if (!( ifs.bad() || ifs.fail())) {
		std::ofstream ofs(dest.c_str(), std::ios::binary);
		ofs << ifs.rdbuf();
		ofs.close();
	}
	ifs.close();
}



std::string& StringToUpper(std::string& str)
{
	unsigned int len = str.length();
	for(unsigned int i=0;i<len;i++) 
		str[i] = toupper(str[i]);
	return str;
}


std::string& StringToLower(std::string& str)
{
	unsigned int len = str.length();
	for(unsigned int i=0;i<len;i++) 
		str[i] = tolower(str[i]);
	return str;
}




// Description: Generates and returns a random number from a normal distribution.
//
// Code From:
// http://www.cs.wm.edu/~va/software/park/rvgs.c
//
// Returns: A random number with a normal distribution.
//
// Arguments:
//   u: draw from a uniform distribution.
//   m: Mean of the normal distribution (default value of 0.0).
//   s: Standard deviation of the normal distribution (default value of 1.0).
double normal_dist( double u, double m, double s )
{
/* ========================================================================
 * Returns a normal (Gaussian) distributed real number.
 * NOTE: use s > 0.0
 *
 * Uses a very accurate approximation of the normal idf due to Odeh & Evans, 
 * J. Applied Statistics, 1974, vol 23, pp 96-97.
 * ========================================================================
 */
  const double p0 = 0.322232431088;     const double q0 = 0.099348462606;
  const double p1 = 1.0;                const double q1 = 0.588581570495;
  const double p2 = 0.342242088547;     const double q2 = 0.531103462366;
  const double p3 = 0.204231210245e-1;  const double q3 = 0.103537752850;
  const double p4 = 0.453642210148e-4;  const double q4 = 0.385607006340e-2;
  double t, p, q, z;

	// inverse normal distribution function is finite on (0,1) reaching +/- infinity at the limits
	// these adjustments prevent from having to deal with infinite values
  if(u == 0.0) u = std::numeric_limits<double>::epsilon();
  else if(u == 1.0) u = 1.0 - std::numeric_limits<double>::epsilon();
  
  if (u < 0.5)
    t = sqrt(-2.0 * log(u));
  else
    t = sqrt(-2.0 * log(1.0 - u));
  p   = p0 + t * (p1 + t * (p2 + t * (p3 + t * p4)));
  q   = q0 + t * (q1 + t * (q2 + t * (q3 + t * q4)));
  if (u < 0.5)
    z = (p / q) - t;
  else
    z = t - (p / q);
  return (m + s * z);
}

int readbetas(std::istream &istrm, std::vector<double>& temp_coeffs, std::vector<double>& temp_perturbs, std::vector<IVariable*>& temp_vars, std::map<std::string, double>& specials, IVariableProvider* vp) {

  std::string buf;
  char bufline[5000];

  unsigned int nvars = 0;
  double x;
  while(!istrm.eof())
    {
      // Read a line
      istrm.getline(bufline, 5000);
      // Check that a full line was read, and that it is not a comment line 
      if(strlen(bufline) > 0 && bufline[0] != '|' && !(bufline[0]=='o' && bufline[1]=='.'))  {
	if(temp_coeffs.size() <= nvars) temp_coeffs.resize(nvars+50);
	if(temp_perturbs.size() <= nvars) temp_perturbs.resize(nvars+50);
	if(temp_vars.size() <= nvars) temp_vars.resize(nvars+50);
	// It is a regular variable coeffecient line.
	std::istringstream iss(bufline);
	iss >>buf >> x;
	if(iss.fail()) {
	  std::string tstring = std::string(bufline);
	  if(tstring.find("(dropped)")==std::string::npos) {
	    // Something bad happened trying to read the data. 
	    // Most likely, it tried to read the coeff but it wasnt a number
	    // Throw an exception
	    std::ostringstream ss;
	    ss << "There was problem reading the line \"" << bufline << "\". Please check the model defination file";
	    throw fem_exception(ss.str().c_str());
	  }
	  else continue;
	}
	if(vp->exists(buf)) {
	  temp_coeffs.at(nvars) = x;
	  temp_vars.at(nvars) = vp->get(buf);
	  nvars++;
	} else {
	  specials[buf] = x;
	}
      } else if (strcmp(bufline, "| Root Mean Square Error") == 0) { 
	// The next line should be the rmse. It is of the form
	// _rmse	#####
	istrm.getline(bufline, 5000);
	std::istringstream iss(bufline);
	iss >>buf >> specials["esigma"];
	if(iss.fail()) {
	  // Something bad happened trying to read the data. 
	  // Most likely, it tried to read the coeff but it wasnt a number
	  // Throw an exception
	  std::ostringstream ss;
	  ss << "There was problem reading the line \"" << bufline << "\". Please check the model defination file";
	  throw fem_exception(ss.str().c_str());
	}
      }
    }
  return nvars;
}
