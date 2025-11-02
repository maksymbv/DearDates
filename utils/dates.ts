export const calculateNextBirthday = (birthdate: string): Date => {
  const [year, month, day] = birthdate.split('-').map(Number);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const thisYearBirthday = new Date(today.getFullYear(), month - 1, day);
  thisYearBirthday.setHours(0, 0, 0, 0);
  
  if (thisYearBirthday >= today) {
    return thisYearBirthday;
  } else {
    return new Date(today.getFullYear() + 1, month - 1, day);
  }
};

export const daysUntilBirthday = (birthdate: string): number => {
  const nextBirthday = calculateNextBirthday(birthdate);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const diffTime = nextBirthday.getTime() - today.getTime();
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  return diffDays;
};

export const formatDate = (dateString: string): string => {
  const [year, month, day] = dateString.split('-').map(Number);
  return `${day.toString().padStart(2, '0')}.${month.toString().padStart(2, '0')}.${year}`;
};

export const formatShortDate = (dateString: string): string => {
  const [year, month, day] = dateString.split('-').map(Number);
  return `${day.toString().padStart(2, '0')}.${month.toString().padStart(2, '0')}.${year}`;
};

export const getAge = (birthdate: string): number => {
  const [year, month, day] = birthdate.split('-').map(Number);
  const today = new Date();
  let age = today.getFullYear() - year;
  const monthDiff = today.getMonth() - (month - 1);
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < day)) {
    age--;
  }
  
  return age;
};

