function M = skew(V)

assert(isvector(V) && length(V) == 3);

M = [
      0 -V(3)  V(2)
   V(3)     0 -V(1)
  -V(2)  V(1)    0
  ];
