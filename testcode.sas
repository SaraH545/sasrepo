*POvIV Quarterly Table 3;
data poviv.QRTable3;
set poviv.poviv_new;
if crf00_complete=2;
screened=1;
if inex_elac13n=1 or (inex_elac18=1 and treat_assign ne 0 and treat_assign ne 1) then not_eligible_ct=1;
else not_eligible_ct=0;
array fractures {9} inex_inc01___1-inex_inc01___9;
do i=1 to 9;
if fractures{i}=1 then fracture=0;
end;
if fracture=. then fracture=1;
if inex_inc02=0 then age=1;
else age=0;
if inex_ici30=0 then treatment_suit_med=1;
else treatment_suit_med=0;
if treatment_suit_med=0 and inex_random_no=1 then treatment_suit_access=1;
else treatment_suit_access=0;
array others {9} inex_exc03-inex_exc11;
do i=1 to 9;
if others{i}=1 then other=1;
end;
if other=. then other=0;
keep study_id facilitycode screened not_eligible_ct age fracture treatment_suit_med treatment_suit_access other;
run;

proc means data=poviv.QRTable3 noprint;
class facilitycode;
var screened not_eligible_ct age fracture treatment_suit_med treatment_suit_access other;
output out=poviv.QRTable3 sum(screened not_eligible_ct age fracture treatment_suit_med treatment_suit_access other)=screened not_eligible_ct 
age fracture treatment_suit_med treatment_suit_access other;
run;

data poviv.QRTable3;
set poviv.QRTable3;
if facilitycode='' then facilitycode='ALL';
not_eligible_pct=round((not_eligible_ct*100/screened),.1);
run;

data poviv.QRTable3;
merge poviv.QRTable3 poviv.monthly_table1;
by facilitycode;
run;
data poviv.QRTable3;
set poviv.QRTable3;
if screened_ct gt 0 and not_eligible_ct=. then not_eligible='0 (0.0\%)';
else if screened_ct gt 0 then not_eligible=trim(left(put(not_eligible_ct,best8.)))||' ('||trim(left(put(not_eligible_pct,best8.)))||'\%)';
else if screened_ct=0 then not_eligible='-';
run;

data poviv.QRTable3;
set poviv.QRTable3;
file 'G:\METRC\POvIV\QRtable3.tex';
put @1 facilitycode
@10 '&'
@12 screened_ct
@22 '&'
@24 not_eligible
@40 '&'
@50 age
@60 '&'
@62 fracture
@70 '&'
@72 treatment_suit_med
@80 '&'
@82 treatment_suit_access
@90 '&'
@92 other
@100 '\\ \hline ';
run;
