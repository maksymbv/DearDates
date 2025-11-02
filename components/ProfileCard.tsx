import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Cake } from 'lucide-react-native';
import { ProfileWithGifts } from '../context/ProfilesContext';
import { formatShortDate, getAge } from '../utils/dates';
import { AnimalAvatar } from './AnimalAvatar';

interface ProfileCardProps {
  profile: ProfileWithGifts;
  onPress: () => void;
}

export const ProfileCard: React.FC<ProfileCardProps> = ({ profile, onPress }) => {
  const age = getAge(profile.birthdate);
  const daysUntil = profile.daysUntil ?? 999;
  
  const getDaysUntilText = () => {
    if (daysUntil === 0) return 'Сегодня! 🎉';
    if (daysUntil === 1) return 'Завтра! 🎈';
    const lastDigit = daysUntil % 10;
    const lastTwoDigits = daysUntil % 100;
    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return `Через ${daysUntil} дней`;
    }
    if (lastDigit === 1) {
      return `Через ${daysUntil} день`;
    }
    if (lastDigit >= 2 && lastDigit <= 4) {
      return `Через ${daysUntil} дня`;
    }
    return `Через ${daysUntil} дней`;
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      style={styles.card}
      activeOpacity={0.7}
    >
      <View style={styles.content}>
        <AnimalAvatar seed={profile.id} size={56} />
        <View style={styles.textContainer}>
          <View style={styles.leftSection}>
            <Text style={styles.name}>{profile.name}</Text>
            <View style={styles.metaContainer}>
              <Cake size={22} color="#2E2E2E" style={styles.cakeIcon} />
              <Text style={styles.meta}>
                {formatShortDate(profile.birthdate)} ({age} лет)
              </Text>
            </View>
          </View>
          <View style={styles.rightSection}>
            <Text style={styles.daysUntil}>
              {getDaysUntilText()}
            </Text>
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#E8E0DB',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 2,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  textContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  leftSection: {
    flex: 1,
  },
  rightSection: {
    alignItems: 'flex-end',
  },
  name: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2E2E2E',
    marginBottom: 4,
  },
  metaContainer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: 6,
  },
  cakeIcon: {
    opacity: 0.7,
  },
  meta: {
    fontSize: 16,
    color: '#2E2E2E',
    opacity: 0.7,
  },
  daysUntil: {
    fontSize: 16,
    fontWeight: '500',
    color: '#D68A9E',
  },
});
