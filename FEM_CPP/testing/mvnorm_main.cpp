#include <cmath>
#include <iostream>
#include <iomanip>
#include <vector>
#include "../RandomBlowfish.h"
#include "../RandomBasic.h"
#include "../RandomTable.h"

/** length of random vectors used for testing */
#define TEST_SIZE 5
/** number of Monte Carlo draws used for testing */
#define NDRAWS 5000000

/** Testing code for multivarite normal random generation. 
Creates NDRAWS Monte Carlo draws, estimate sample moments and compare to true values.
\todo This only tests the implementation through RandomBlowfish.  RandomBasic and RandomTable implementations should also be tested.
*/
int main(int argc, char** argv) {
    RandomBlowfish blowfish_test(1091638739, 1);
 
 		// set up mean and covariance parameters
 		std::vector<double> mean_true(TEST_SIZE);
 		std::vector< std::vector<double> > C(TEST_SIZE);
 		for(unsigned int i=0; i < TEST_SIZE; i++) {
 			mean_true[i] = 100*(i+1); 
 			C[i].resize(i+1);
 			for(unsigned int j=0; j <= i; j++) {
 				C[i][j] = (i+1) + (j+1);
 				if(i != j) {
 					int s = 0;
 					int t = ((j+1) % (i+1)) - ((TEST_SIZE / 2)+1);
 					if(t < 0)
 						s = -1;
 					else if(t > 0)
 						s = 1;
 					C[i][j] *= s;
 				}
 			}
   	}
   	double cov_true[TEST_SIZE][TEST_SIZE];
   	for(unsigned int i=0; i < TEST_SIZE; i++)
   		for(unsigned int j=0; j <= i; j++) {
   			cov_true[i][j] = cov_true[j][i] = 0.0;
   			for(unsigned int k=0; k <= std::min(i,j); k++) {
   				cov_true[i][j] += C[i][k] * C[j][k];
   			}
   			cov_true[j][i] = cov_true[i][j];
   		}
   			
   	// generate random draws
   	unsigned int id = 10000;
   	std::vector<unsigned int> process(TEST_SIZE);
   	for(unsigned int i=0; i < TEST_SIZE; i++)
   		process[i] = i+1;
   	unsigned int year = 2020;
   	std::vector< std::vector<double> > draws(NDRAWS);
   	for(unsigned int i=0; i < NDRAWS; i++) {
   		std::vector<double> d = blowfish_test.mvnormDist(id, process, year + i, mean_true, C);
   		draws[i] = d;
   		/*
   		std::cout << std::endl << "Draw " << i+1 << ": " << d[0];
   		for(unsigned int j=1; j < TEST_SIZE; j++)
   			std::cout << "\t" << draws[i][j];
   		std::cout << std::endl;
   		*/
   	}
   	
   	/////// estimate first four moments and covariance
   	std::vector<double> mean_est(TEST_SIZE);
   	std::vector<double> skew_est(TEST_SIZE);
   	std::vector<double> kurt_est(TEST_SIZE);
		double cov_est[TEST_SIZE][TEST_SIZE];
		
		// initialize estimates
		for(unsigned int i=0; i < TEST_SIZE; i++) {
			mean_est[i] = 0.0;
			skew_est[i] = 0.0;
			kurt_est[i] = 0.0;
			for(unsigned int j=0; j < TEST_SIZE; j++)
				cov_est[i][j] = 0.0;
		}

		// compute mean estimates
		for(unsigned int i=0; i < NDRAWS; i++)
			for(unsigned int j=0; j < TEST_SIZE; j++)
				mean_est[j] += draws[i][j];
		for(unsigned int i=0; i < TEST_SIZE; i++)
				mean_est[i] /= NDRAWS;
				
		// compute covariance matrix estimate
		for(unsigned int i=0; i < NDRAWS; i++)
			for(unsigned int j=0; j < TEST_SIZE; j++)
				for(unsigned int k=0; k < TEST_SIZE; k++)
					cov_est[j][k] += (draws[i][j] - mean_est[j])*(draws[i][k] - mean_est[k]);
		for(unsigned int i=0; i < TEST_SIZE; i++)
			for(unsigned int j=0; j < TEST_SIZE; j++)
				cov_est[i][j] /= (NDRAWS - 1);
		
		// compute marginal skewness estimates
		for(unsigned int i=0; i < NDRAWS; i++)
			for(unsigned int j=0; j < TEST_SIZE; j++)
					skew_est[j] += pow(draws[i][j] - mean_est[j], 3);
		for(unsigned int i=0; i < TEST_SIZE; i++)
			skew_est[i] = sqrt(1.0 - 1.0/NDRAWS) * skew_est[i] / ((NDRAWS - 2) * pow(cov_est[i][i] * (NDRAWS - 1) / NDRAWS, 1.5));

		// compute marginal kurtosis estimate
		for(unsigned int i=0; i < NDRAWS; i++)
			for(unsigned int j=0; j < TEST_SIZE; j++)
					kurt_est[j] += pow(draws[i][j] - mean_est[j], 4);
		for(unsigned int i=0; i < TEST_SIZE; i++)
			kurt_est[i] = kurt_est[i] / (NDRAWS * pow(cov_est[i][i] * (NDRAWS - 1) / NDRAWS, 2));


  	std::cout << std::setprecision(4);
   	// compare estimates to true values
   	std::cout << "Number of MC draws = " << NDRAWS << std::endl;
   	std::cout << "--== True values ==--" << std::endl;
   	std::cout << "Mean: " << mean_true[0];
   	for(unsigned int i=1; i < TEST_SIZE; i++)
			std::cout << '\t' << mean_true[i];
		std::cout << std::endl;
		std::cout << "Covariance: " << std::endl;
		for(unsigned int i=0; i < TEST_SIZE; i++) {
			std::cout << 'x' << i+1 << ": ";
			for(unsigned int j=0; j < TEST_SIZE; j++)
				std::cout << '\t' << std::setw(6) << cov_true[i][j];
			std::cout << std::endl;		
		}
		std::cout << "Correlation: " << std::endl;
		for(unsigned int i=0; i < TEST_SIZE; i++) {
			std::cout << 'x' << i+1 << ": ";
			for(unsigned int j=0; j < TEST_SIZE; j++)
				std::cout << '\t' << std::setw(7) << cov_true[i][j] / (sqrt(cov_true[i][i])*sqrt(cov_true[j][j]));
			std::cout << std::endl;		
		}
		
		
		std::cout << std::endl << "--== Estimates ==--" << std::endl;
   	std::cout << "Mean: " << mean_est[0];
   	for(unsigned int i=1; i < TEST_SIZE; i++)
			std::cout << '\t' << mean_est[i];
		std::cout << std::endl;
		std::cout << "Covariance: " << std::endl;
		for(unsigned int i=0; i < TEST_SIZE; i++) {
			std::cout << 'x' << i+1 << ": ";
			for(unsigned int j=0; j < TEST_SIZE; j++)
				std::cout << '\t' << std::setw(6) << cov_est[i][j];
			std::cout << std::endl;		
		}


   	
   	std::cout << std::endl << "--== Diff. between estimates and true values ==--" << std::endl;
   	std::cout << "Mean: " << mean_est[0] - mean_true[0];
   	for(unsigned int i=1; i < TEST_SIZE; i++)
			std::cout << '\t' << mean_est[i] - mean_true[i];
		std::cout << std::endl;
		std::cout << "Covariance: " << std::endl;
		for(unsigned int i=0; i < TEST_SIZE; i++) {
			std::cout << 'x' << i+1 << ": ";
			for(unsigned int j=0; j < TEST_SIZE; j++)
				std::cout << '\t' << std::setw(8) << cov_est[i][j] - cov_true[i][j];
			std::cout << std::endl;		
		}
		std::cout << "Marginal skewness: " << skew_est[0];
   	for(unsigned int i=1; i < TEST_SIZE; i++)
			std::cout << '\t' << skew_est[i];
		std::cout << std::endl;
		std::cout << "Marginal excess kurtosis (naive/biased estimate): " << kurt_est[0] - 3.0;
   	for(unsigned int i=1; i < TEST_SIZE; i++)
			std::cout << '\t' << kurt_est[i] - 3.0;
		std::cout << std::endl;
}
