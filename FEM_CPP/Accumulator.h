#pragma once
#include <vector>
#include <algorithm>
#include "utility.h"

class Accumulator 
{
public:
	virtual void reset() = 0;
	virtual void accum(double val, double weight) = 0;
	virtual double value() = 0;
	virtual Accumulator* clone() = 0;
	virtual ~Accumulator() {}
};

class AccumulatorSum : public Accumulator
{
public:
	AccumulatorSum() {reset();}
	virtual ~AccumulatorSum() {}
	virtual void reset()  {v = 0.0;}
	virtual void accum(double val, double weight) {v+= val*weight;}
	virtual double value() {return v;}
	virtual Accumulator* clone() {return new AccumulatorSum();}
protected:
	double v;
};

class AccumulatorMean : public Accumulator
{
public:
	AccumulatorMean() {reset();}
	virtual ~AccumulatorMean() {}
	virtual void reset() {num = 0.0; denom = 0.0;}
	virtual void accum(double val, double weight) {num += val*weight; denom += weight;}
	virtual double value() {return denom != 0.0 ? num/denom : 0.0;}
	virtual Accumulator* clone() {return new AccumulatorMean();}
protected:
	double num, denom;
};


class AccumulatorMedian : public Accumulator
{
public:
	AccumulatorMedian() { vec.reserve(15000);  reset();}
	virtual ~AccumulatorMedian() {}
	virtual void reset() {vec.clear();  ttl_wt = 0.0;}
	virtual void accum(double val, double weight) {val_wt v; v.val = val; v.wt = weight; vec.push_back(v); ttl_wt += weight;}
	virtual double value() {
		std::sort(vec.begin(), vec.end(), comp_valwt);
		double cum_wt = 0.0;
		for(unsigned int i = 0; i < vec.size(); i++) {
			cum_wt += vec[i].wt;
			if(cum_wt >= ttl_wt / 2.0)
				return vec[i].val;
		}
		return 0.0;
	}
	virtual Accumulator* clone() {return new AccumulatorMedian();}
protected:
	typedef struct val_wt {
		double val;
		double wt;
	} val_wt;
	std::vector<val_wt> vec;
	double ttl_wt;
	static bool comp_valwt(const val_wt &x, const val_wt &y) { return x.val < y.val;}
};

class AccumulatorMinimum : public Accumulator {
 public:
  AccumulatorMinimum() { vec.reserve(15000); reset();}
  virtual ~AccumulatorMinimum() {}
  virtual void reset() {vec.clear();}
  virtual void accum(double val, double weight) {if(weight > 0) vec.push_back(val);}
  virtual double value() {
    std::sort(vec.begin(), vec.end());
    return vec.front();
  }
  virtual Accumulator* clone() {return new AccumulatorMinimum();}
 protected:
  std::vector<double> vec;
};

class AccumulatorMaximum : public Accumulator {
 public:
  AccumulatorMaximum() { vec.reserve(15000); reset();}
  virtual ~AccumulatorMaximum() {}
  virtual void reset() {vec.clear();}
  virtual void accum(double val, double weight) {if(weight > 0) vec.push_back(val);}
  virtual double value() {
    std::sort(vec.begin(), vec.end());
    return vec.back();
  }
  virtual Accumulator* clone() {return new AccumulatorMaximum();}
 protected:
  std::vector<double> vec;
};

class AccumulatorQuantile : public Accumulator {
 public:
  AccumulatorQuantile(double q) {quant_level = q; vec.reserve(15000); reset();}
  virtual ~AccumulatorQuantile() {}
  virtual void reset() {vec.clear(); ttl_wt=0.0;}
  virtual void accum(double val, double weight) {val_wt v; v.val = val; v.wt = weight; vec.push_back(v); ttl_wt += weight;}
  virtual double value() {
    std::sort(vec.begin(), vec.end(), comp_valwt);
    double cum_wt = 0.0;
    for(unsigned int i = 0; i < vec.size(); i++) {
      cum_wt += vec[i].wt;
      if(cum_wt >= ttl_wt * quant_level)
	return vec[i].val;
    }
    return 0.0;
  }
  virtual Accumulator* clone() {return new AccumulatorQuantile(quant_level);}
 protected:
  double quant_level;
  typedef struct val_wt {
    double val;
    double wt;
  } val_wt;
  std::vector<val_wt> vec;
  double ttl_wt;
  static bool comp_valwt(const val_wt &x, const val_wt &y) { return x.val < y.val;}
};
