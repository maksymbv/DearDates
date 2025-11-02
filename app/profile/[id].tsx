import React, { useEffect, useState } from 'react';
import { View, Text, ScrollView, TouchableOpacity, TextInput, Alert } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { PhosphorIcon } from '../../components/PhosphorIcon';
import { useStore } from '../../store/useStore';
import { ProfileWithGifts } from '../../store/useStore';
import { formatDate, getAge } from '../../utils/dates';

export default function ProfileScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const profileId = id || '';

  const { profiles, deleteProfile, addGift, updateGiftStatus, deleteGift } =
    useStore();

  const [profile, setProfile] = useState<ProfileWithGifts | null>(null);
  const [newGiftIdea, setNewGiftIdea] = useState('');

  useEffect(() => {
    const foundProfile = profiles.find((p) => p.id === profileId);
    if (foundProfile) {
      setProfile(foundProfile);
    }
  }, [profiles, profileId]);

  const handleAddGift = async () => {
    if (!newGiftIdea.trim()) {
      Alert.alert('Ошибка', 'Пожалуйста, введите идею подарка');
      return;
    }

    try {
      await addGift(profileId, newGiftIdea.trim());
      setNewGiftIdea('');
    } catch (error) {
      Alert.alert('Ошибка', 'Не удалось добавить подарок');
      console.error(error);
    }
  };

  const handleDelete = () => {
    Alert.alert(
      'Удалить профиль',
      'Вы уверены, что хотите удалить этот профиль?',
      [
        { text: 'Отмена', style: 'cancel' },
        {
          text: 'Удалить',
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteProfile(profileId);
              router.back();
            } catch (error) {
              Alert.alert('Ошибка', 'Не удалось удалить профиль');
            }
          },
        },
      ]
    );
  };

  if (!profile) {
    return (
      <View className="flex-1 items-center justify-center">
        <Text className="text-gray-500">Профиль не найден</Text>
      </View>
    );
  }

  const age = getAge(profile.birthdate);
  const pastGifts = profile.gifts.filter((g) => g.is_given === 1);
  const futureGifts = profile.gifts.filter((g) => g.is_given === 0);

  return (
    <ScrollView className="flex-1 bg-gray-50 px-4 pt-4">
      <View className="bg-white rounded-xl p-6 mb-4">
        <Text className="text-2xl font-bold text-gray-900 mb-2">
          {profile.name}
        </Text>
        <Text className="text-base text-gray-600 mb-1">
          {age} лет
        </Text>
        {profile.relationship && (
          <Text className="text-base text-gray-600 mb-1">
            {profile.relationship}
          </Text>
        )}
        <Text className="text-sm text-gray-500 mt-2">
          {formatDate(profile.birthdate)}
        </Text>
        {profile.notes && (
          <Text className="text-base text-gray-700 mt-4">
            {profile.notes}
          </Text>
        )}
        
        <View className="flex-row gap-3 mt-6 pt-4 border-t border-gray-200">
          <TouchableOpacity
            onPress={() => router.push(`/edit-profile/${profileId}`)}
            className="flex-1 bg-blue-500 rounded-lg py-3 items-center justify-center flex-row gap-2"
            activeOpacity={0.7}
          >
            <PhosphorIcon icon="pencil" size={20} color="white" weight="bold" />
            <Text className="text-white font-medium">Редактировать</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={handleDelete}
            className="flex-1 bg-red-500 rounded-lg py-3 items-center justify-center flex-row gap-2"
            activeOpacity={0.7}
          >
            <PhosphorIcon icon="trash" size={20} color="white" weight="bold" />
            <Text className="text-white font-medium">Удалить</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View className="bg-white rounded-xl p-4 mb-4">
        <Text className="text-lg font-semibold text-gray-900 mb-3">Идеи подарков</Text>
        
        <View className="flex-row gap-2 mb-4">
          <TextInput
            value={newGiftIdea}
            onChangeText={setNewGiftIdea}
            placeholder="Добавить идею подарка..."
            className="flex-1 border border-gray-200 rounded-lg px-4 py-3"
            onSubmitEditing={handleAddGift}
          />
          <TouchableOpacity
            onPress={handleAddGift}
            className="bg-blue-500 rounded-lg px-4 py-3 items-center justify-center"
            activeOpacity={0.7}
          >
            <PhosphorIcon icon="plus" size={20} color="white" weight="bold" />
          </TouchableOpacity>
        </View>

        {futureGifts.length > 0 && (
          <View className="mb-4">
            <Text className="text-sm font-medium text-gray-700 mb-2">Запланированные</Text>
            {futureGifts.map((gift) => (
              <View key={gift.id} className="flex-row items-center justify-between bg-gray-50 rounded-lg p-3 mb-2">
                <Text className="flex-1 text-base text-gray-900">{gift.idea}</Text>
                <View className="flex-row gap-2">
                  <TouchableOpacity
                    onPress={() => updateGiftStatus(gift.id, true)}
                    className="px-3 py-2 bg-green-100 rounded-lg items-center justify-center"
                    activeOpacity={0.7}
                  >
                    <PhosphorIcon icon="check" size={18} color="#15803d" weight="bold" />
                  </TouchableOpacity>
                  <TouchableOpacity
                    onPress={() => {
                      Alert.alert(
                        'Удалить подарок',
                        'Вы уверены?',
                        [
                          { text: 'Отмена', style: 'cancel' },
                          {
                            text: 'Удалить',
                            style: 'destructive',
                            onPress: () => deleteGift(gift.id),
                          },
                        ]
                      );
                    }}
                    className="px-3 py-2 bg-red-100 rounded-lg items-center justify-center"
                    activeOpacity={0.7}
                  >
                    <PhosphorIcon icon="trash" size={18} color="#dc2626" weight="bold" />
                  </TouchableOpacity>
                </View>
              </View>
            ))}
          </View>
        )}

        {pastGifts.length > 0 && (
          <View>
            <Text className="text-sm font-medium text-gray-700 mb-2">Уже подарено</Text>
            {pastGifts.map((gift) => (
              <View key={gift.id} className="flex-row items-center justify-between bg-gray-50 rounded-lg p-3 mb-2">
                <Text className="flex-1 text-base text-gray-500 line-through">{gift.idea}</Text>
                <TouchableOpacity
                  onPress={() => {
                    Alert.alert(
                      'Удалить подарок',
                      'Вы уверены?',
                      [
                        { text: 'Отмена', style: 'cancel' },
                        {
                          text: 'Удалить',
                          style: 'destructive',
                          onPress: () => deleteGift(gift.id),
                        },
                      ]
                    );
                  }}
                  className="px-3 py-2 bg-red-100 rounded-lg items-center justify-center"
                  activeOpacity={0.7}
                >
                  <PhosphorIcon icon="trash" size={18} color="#dc2626" weight="bold" />
                </TouchableOpacity>
              </View>
            ))}
          </View>
        )}

        {profile.gifts.length === 0 && (
          <Text className="text-gray-400 text-sm text-center py-4">
            Пока нет идей подарков. Добавьте первую!
          </Text>
        )}
      </View>
    </ScrollView>
  );
}
