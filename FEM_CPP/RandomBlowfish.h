#pragma once

#include "Random.h"


// Description: Structure used to facilitate some of the byte-wise
// operations of the blowfish algorithm
//
// Remarks: It allows for access to individual bytes of a 32-bit word in a
// convenient manner, as far as C is concerned.
typedef union {
  unsigned w;              // The 32-bit word as a word.
  unsigned char bytes[4];  // The 32 bits as an array of 4 8-bit bytes.
  struct {
    unsigned byte3:8;      // First byte of the 32-bit word.
    unsigned byte2:8;      // Second byte of the 32-bit word.
    unsigned byte1:8;      // Third byte of the 32-bit word.
    unsigned byte0:8;      // Fourth byte of the 32-bit word.
  } p;                     // Structure holding 4 8-bit bytes.
} word_T;                  // Union of 3 ways of depicting a 32-bit word.


class RandomBlowfish : public Random
{
private:
	// Indicator for the seed already being set.
	bool alreadySetup;
	// The seed for the generator.
	unsigned int seed;
	void encrypt( unsigned *block_left, unsigned *block_right ) const;
	void keySchedule( unsigned char *key );
	void set_pi();
	unsigned Feistel( word_T x ) const;


	// Blowfish uses two important tables, 8x32 bit S-boxes 
	// (substitution look up tables) and a permutation array which
	// is used by the algorithm as a round key.
	unsigned p[18];
	unsigned s[4][256];
	
	unsigned getRand( unsigned id32, unsigned id16_1, unsigned id16_2 ) const;
public:
	RandomBlowfish(unsigned int seed, unsigned int r);
	virtual ~RandomBlowfish() {}
	void setSeed(unsigned int newSeed );
	void setup();
	
	virtual double normalDist( unsigned int id,  unsigned int process, unsigned int year, double m, double s ) const;
	virtual double uniformDist( unsigned int id,  unsigned int random_process, unsigned int year ) const;
	virtual unsigned int randomIndex(unsigned int id, Random_t rand) const;
	
	
};
