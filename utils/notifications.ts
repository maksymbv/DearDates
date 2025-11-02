import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';
import { calculateNextBirthday } from './dates';

// Configure notification handler
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export const requestPermissions = async (): Promise<boolean> => {
  const { status: existingStatus } = await Notifications.getPermissionsAsync();
  let finalStatus = existingStatus;
  
  if (existingStatus !== 'granted') {
    const { status } = await Notifications.requestPermissionsAsync();
    finalStatus = status;
  }
  
  if (finalStatus !== 'granted') {
    return false;
  }
  
  if (Platform.OS === 'android') {
    await Notifications.setNotificationChannelAsync('birthdays', {
      name: 'Дни рождения',
      importance: Notifications.AndroidImportance.HIGH,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: '#FF231F7C',
    });
  }
  
  return true;
};

export const scheduleBirthdayNotification = async (
  profileId: number,
  name: string,
  birthdate: string
): Promise<string | null> => {
  try {
    const nextBirthday = calculateNextBirthday(birthdate);
    const daysUntil = Math.floor(
      (nextBirthday.getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
    );
    
    // Schedule notification 3 days before birthday
    if (daysUntil >= 3) {
      const triggerDate = new Date(nextBirthday);
      triggerDate.setDate(triggerDate.getDate() - 3);
      triggerDate.setHours(9, 0, 0); // 9 AM
      
      // Only schedule if the trigger date is in the future
      if (triggerDate > new Date()) {
        const notificationId = await Notifications.scheduleNotificationAsync({
          content: {
            title: '🎉 Скоро день рождения!',
            body: `Через 3 дня день рождения у ${name}`,
            data: { profileId },
            sound: true,
          },
          trigger: triggerDate,
        });
        
        return notificationId;
      }
    } else if (daysUntil >= 0 && daysUntil < 3) {
      // If birthday is less than 3 days away, schedule for today at 9 AM
      const triggerDate = new Date();
      triggerDate.setHours(9, 0, 0);
      if (triggerDate <= new Date()) {
        triggerDate.setDate(triggerDate.getDate() + 1);
        triggerDate.setHours(9, 0, 0);
      }
      
      if (triggerDate < nextBirthday) {
        const notificationId = await Notifications.scheduleNotificationAsync({
          content: {
            title: '🎉 Скоро день рождения!',
            body: `Через ${daysUntil} ${daysUntil === 1 ? 'день' : daysUntil === 0 ? 'сегодня' : 'дня'} день рождения у ${name}`,
            data: { profileId },
            sound: true,
          },
          trigger: triggerDate,
        });
        
        return notificationId;
      }
    }
    
    return null;
  } catch (error) {
    console.error('Error scheduling notification:', error);
    return null;
  }
};

export const cancelNotification = async (notificationId: string): Promise<void> => {
  await Notifications.cancelScheduledNotificationAsync(notificationId);
};

export const cancelAllNotifications = async (): Promise<void> => {
  await Notifications.cancelAllScheduledNotificationsAsync();
};

