import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { PhosphorIcon } from '../components/PhosphorIcon';
import { useStore } from '../store/useStore';

export default function AddProfileScreen() {
  const router = useRouter();
  const addProfile = useStore((state) => state.addProfile);
  
  const [name, setName] = useState('');
  const [day, setDay] = useState('');
  const [month, setMonth] = useState('');
  const [year, setYear] = useState('');
  const [relationship, setRelationship] = useState('');
  const [notes, setNotes] = useState('');

  const handleSave = async () => {
    if (!name.trim()) {
      Alert.alert('Ошибка', 'Пожалуйста, введите имя');
      return;
    }

    const dayNum = parseInt(day) || 1;
    const monthNum = parseInt(month) || 1;
    const yearNum = parseInt(year) || 2000;

    // Валидация даты
    if (dayNum < 1 || dayNum > 31) {
      Alert.alert('Ошибка', 'Введите корректный день (1-31)');
      return;
    }
    if (monthNum < 1 || monthNum > 12) {
      Alert.alert('Ошибка', 'Введите корректный месяц (1-12)');
      return;
    }
    if (yearNum < 1900 || yearNum > new Date().getFullYear()) {
      Alert.alert('Ошибка', 'Введите корректный год');
      return;
    }

    // Проверка корректности даты
    const date = new Date(yearNum, monthNum - 1, dayNum);
    if (date.getDate() !== dayNum || date.getMonth() !== monthNum - 1 || date.getFullYear() !== yearNum) {
      Alert.alert('Ошибка', 'Введите корректную дату');
      return;
    }

    try {
      const dateString = `${yearNum}-${monthNum.toString().padStart(2, '0')}-${dayNum.toString().padStart(2, '0')}`;
      await addProfile(
        name.trim(),
        dateString,
        relationship.trim() || undefined,
        notes.trim() || undefined
      );
      router.back();
    } catch (error) {
      Alert.alert('Ошибка', 'Не удалось сохранить профиль');
      console.error(error);
    }
  };

  const formatDateForDisplay = () => {
    const dayNum = parseInt(day) || 1;
    const monthNum = parseInt(month) || 1;
    const yearNum = parseInt(year) || 2000;
    if (day && month && year) {
      return `${dayNum.toString().padStart(2, '0')}.${monthNum.toString().padStart(2, '0')}.${yearNum}`;
    }
    return '';
  };

  return (
    <ScrollView className="flex-1 bg-gray-50 px-4 pt-4">
      <View className="bg-white rounded-xl p-4 mb-4">
        <Text className="text-sm font-medium text-gray-700 mb-2">Имя *</Text>
        <TextInput
          value={name}
          onChangeText={setName}
          placeholder="Введите имя"
          className="border border-gray-200 rounded-lg px-4 py-3 text-base"
          autoFocus
        />
      </View>

      <View className="bg-white rounded-xl p-4 mb-4">
        <Text className="text-sm font-medium text-gray-700 mb-2">Дата рождения *</Text>
        <View className="flex-row gap-2">
          <TextInput
            value={day}
            onChangeText={(text) => {
              // Разрешаем только цифры
              const numericText = text.replace(/[^0-9]/g, '');
              if (numericText === '' || (parseInt(numericText) >= 1 && parseInt(numericText) <= 31)) {
                setDay(numericText);
              }
            }}
            placeholder="День"
            keyboardType="numeric"
            maxLength={2}
            className="flex-1 border border-gray-200 rounded-lg px-4 py-3 text-base"
          />
          <TextInput
            value={month}
            onChangeText={(text) => {
              // Разрешаем только цифры
              const numericText = text.replace(/[^0-9]/g, '');
              if (numericText === '' || (parseInt(numericText) >= 1 && parseInt(numericText) <= 12)) {
                setMonth(numericText);
              }
            }}
            placeholder="Месяц"
            keyboardType="numeric"
            maxLength={2}
            className="flex-1 border border-gray-200 rounded-lg px-4 py-3 text-base"
          />
          <TextInput
            value={year}
            onChangeText={(text) => {
              // Разрешаем только цифры
              const numericText = text.replace(/[^0-9]/g, '');
              if (numericText === '' || numericText.length <= 4) {
                setYear(numericText);
              }
            }}
            placeholder="Год"
            keyboardType="numeric"
            maxLength={4}
            className="flex-1 border border-gray-200 rounded-lg px-4 py-3 text-base"
          />
        </View>
        {formatDateForDisplay() && (
          <Text className="text-xs text-gray-400 mt-2">
            {formatDateForDisplay()}
          </Text>
        )}
      </View>

      <View className="bg-white rounded-xl p-4 mb-4">
        <Text className="text-sm font-medium text-gray-700 mb-2">Кто он тебе</Text>
        <TextInput
          value={relationship}
          onChangeText={setRelationship}
          placeholder="Например: друг, брат, коллега..."
          className="border border-gray-200 rounded-lg px-4 py-3 text-base"
        />
      </View>

      <View className="bg-white rounded-xl p-4 mb-4">
        <Text className="text-sm font-medium text-gray-700 mb-2">Заметки</Text>
        <TextInput
          value={notes}
          onChangeText={setNotes}
          placeholder="Дополнительная информация..."
          multiline
          numberOfLines={4}
          className="border border-gray-200 rounded-lg px-4 py-3 text-base"
          textAlignVertical="top"
        />
      </View>

      <View className="flex-row gap-3 mb-6">
        <TouchableOpacity
          onPress={() => router.back()}
          className="flex-1 bg-gray-200 rounded-lg py-3 items-center justify-center flex-row gap-2"
          activeOpacity={0.7}
        >
          <PhosphorIcon icon="x" size={20} color="#111827" weight="bold" />
          <Text className="text-gray-900 font-medium">Отмена</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={handleSave}
          className="flex-1 bg-blue-500 rounded-lg py-3 items-center justify-center flex-row gap-2"
          activeOpacity={0.7}
        >
          <PhosphorIcon icon="check" size={20} color="white" weight="bold" />
          <Text className="text-white font-medium">Сохранить</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}
