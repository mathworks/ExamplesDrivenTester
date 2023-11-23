% Function just adds num1 and num2 and returns sum1 conditionally. Max
% value of sum is 99. If num1 + num2 is greater than 99, sum is returned as
% -1

function sum = addThem(num1, num2)
sum = num1 + num2;

if sum > 99
  sum = -1;
end

end