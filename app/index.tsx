import React, { useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter } from 'expo-router';
import { PhosphorIcon } from '../components/PhosphorIcon';
import { useStore } from '../store/useStore';
import { ProfileCard } from '../components/ProfileCard';
import { EmptyState } from '../components/EmptyState';

export default function HomeScreen() {
  const router = useRouter();
  const { profiles, isLoading, loadProfiles } = useStore();

  useEffect(() => {
    loadProfiles();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <View className="flex-1 bg-gray-50">
      <ScrollView
        className="flex-1 px-4 pt-4"
        refreshControl={
          <RefreshControl refreshing={isLoading} onRefresh={loadProfiles} />
        }
      >
        {profiles.length === 0 && !isLoading ? (
          <EmptyState
            title="Пока нет дней рождения"
            message="Добавьте первый профиль, чтобы начать отслеживать дни рождения и идеи подарков"
          />
        ) : (
          profiles.map((profile) => (
            <ProfileCard
              key={profile.id}
              profile={profile}
              onPress={() => router.push(`/profile/${profile.id}`)}
            />
          ))
        )}
      </ScrollView>

      <TouchableOpacity
        onPress={() => router.push('/add-profile')}
        className="absolute bottom-6 right-6 w-14 h-14 bg-blue-500 rounded-full items-center justify-center shadow-lg"
        activeOpacity={0.8}
      >
        <PhosphorIcon icon="plus" size={28} color="white" weight="bold" />
      </TouchableOpacity>
    </View>
  );
}
