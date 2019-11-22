/** \file process_clmyr.sas This file handles the processing for one year of medicare claims.
    This isn't in a site-level macros library because it is specific to the script that uses it,
    hard-coding filenames and other such things. Useful to have independent just for modularity.

    inputs: medicare claims files, and the year being processed
    outputs: portions of a set statement to load the files

    original author: Jeff Sullivan, March 2013

    $Id: process_clmyr.sas 1 2013-05-29 14:20:02Z jeffreys $
    */

%macro process_clmyr(year);
        clms.ip_&year. (in=ip keep=bid_hrs from_dt hcpscd: dgnscd: prcdrcd: ad_dgns pdgns_cd rename=(ad_dgns=dgnscd11 pdgns_cd=dgnscd12))
        clms.op_&year. (in=op keep=bid_hrs from_dt dgnscd: prcdrcd: hcpscd: rvcntr:)
        clms.pb_&year. (in=pb keep=bid_hrs from_dt dgns_cd: hcpscd: rename=(dgns_cd1-dgns_cd9=dgnscd01-dgnscd09))

    %mend;
