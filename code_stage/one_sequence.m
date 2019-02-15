function [m] = one_sequence(m)

l = m';
[s1,s2] = size(m);
clear m
m = l(1:s1*s2);

f = find(isnan(m)==1);
m(f) = [];
