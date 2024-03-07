//* calculate number of months since first month
int calculateMonthCount(int startYear, startMonth, currentMonth, currentYear){
  int monthCount = 
    (currentYear - startYear) * 12 + (currentMonth - startMonth + 1);
  return monthCount;
}