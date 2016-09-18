function B = generatePlaceBank(T)

interval = 5;

B = 1;
for i = 1:2:length(T)
  if norm(T{i}(1:3,4) - T{B(end)}(1:3,4)) > interval
    B = [B i];
  end
end