import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, Alert, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { X, Check } from 'lucide-react-native';
import { useProfiles } from '../context/ProfilesContext';
import { RootStackParamList } from '../navigation/AppNavigator';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export default function AddProfileScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { addProfile } = useProfiles();
  
  const [name, setName] = useState('');
  const [day, setDay] = useState('');
  const [month, setMonth] = useState('');
  const [year, setYear] = useState('');
  const [notes, setNotes] = useState('');

  const handleSave = async () => {
    if (!name.trim()) {
      Alert.alert('Ошибка', 'Пожалуйста, введите имя');
      return;
    }

    if (!day.trim() || !month.trim() || !year.trim()) {
      Alert.alert('Ошибка', 'Пожалуйста, введите дату рождения');
      return;
    }

    const dayNum = parseInt(day);
    const monthNum = parseInt(month);
    const yearNum = parseInt(year);

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
        notes.trim() || undefined
      );
      navigation.goBack();
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
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.section}>
        <Text style={styles.label}>Имя *</Text>
        <TextInput
          value={name}
          onChangeText={setName}
          placeholder="Введите имя"
          placeholderTextColor="#2E2E2E"
          style={styles.input}
          autoFocus
        />
      </View>

      <View style={styles.section}>
        <Text style={styles.label}>Дата рождения *</Text>
        <View style={styles.dateRow}>
          <TextInput
            value={day}
            onChangeText={(text) => {
              const numericText = text.replace(/[^0-9]/g, '');
              if (numericText === '' || (parseInt(numericText) >= 1 && parseInt(numericText) <= 31)) {
                setDay(numericText);
              }
            }}
            placeholder="День"
            placeholderTextColor="#2E2E2E"
            keyboardType="numeric"
            maxLength={2}
            style={[styles.input, styles.dateInput]}
          />
          <TextInput
            value={month}
            onChangeText={(text) => {
              const numericText = text.replace(/[^0-9]/g, '');
              if (numericText === '' || (parseInt(numericText) >= 1 && parseInt(numericText) <= 12)) {
                setMonth(numericText);
              }
            }}
            placeholder="Месяц"
            placeholderTextColor="#2E2E2E"
            keyboardType="numeric"
            maxLength={2}
            style={[styles.input, styles.dateInput]}
          />
          <TextInput
            value={year}
            onChangeText={(text) => {
              const numericText = text.replace(/[^0-9]/g, '');
              if (numericText === '' || numericText.length <= 4) {
                setYear(numericText);
              }
            }}
            placeholder="Год"
            placeholderTextColor="#2E2E2E"
            keyboardType="numeric"
            maxLength={4}
            style={[styles.input, styles.dateInput]}
          />
        </View>
        {formatDateForDisplay() && (
          <Text style={styles.datePreview}>{formatDateForDisplay()}</Text>
        )}
      </View>

      <View style={styles.section}>
        <Text style={styles.label}>Заметки</Text>
        <TextInput
          value={notes}
          onChangeText={setNotes}
          placeholder="Дополнительная информация..."
          placeholderTextColor="#2E2E2E"
          multiline
          numberOfLines={4}
          style={[styles.input, styles.textArea]}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.buttonRow}>
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={[styles.button, styles.cancelButton]}
          activeOpacity={0.7}
        >
          <X size={20} color="#2E2E2E" />
          <Text style={styles.cancelButtonText}>Отмена</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={handleSave}
          style={[styles.button, styles.saveButton]}
          activeOpacity={0.7}
        >
          <Check size={20} color="white" />
          <Text style={styles.saveButtonText}>Сохранить</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F5F2',
  },
  content: {
    padding: 16,
    paddingTop: 16,
  },
  section: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#E8E0DB',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 2,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#2E2E2E',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#E8E0DB',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: '#ffffff',
    color: '#2E2E2E',
  },
  dateRow: {
    flexDirection: 'row',
    gap: 8,
  },
  dateInput: {
    flex: 1,
  },
  datePreview: {
    fontSize: 12,
    color: '#2E2E2E',
    opacity: 0.6,
    marginTop: 8,
  },
  textArea: {
    minHeight: 100,
    textAlignVertical: 'top',
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 24,
  },
  button: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    paddingVertical: 12,
    borderRadius: 12,
  },
  cancelButton: {
    backgroundColor: '#E8E0DB',
  },
  cancelButtonText: {
    color: '#2E2E2E',
    fontWeight: '500',
  },
  saveButton: {
    backgroundColor: '#D68A9E',
  },
  saveButtonText: {
    color: '#ffffff',
    fontWeight: '500',
  },
});

