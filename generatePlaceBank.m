function B = generatePlaceBank(T)

interval = 5;

B = 1;
for i = 1:size(T,2)
  if norm(T(1:3,i) - T(1:3,B(end))) > 5
    B = [B i];
  end
end