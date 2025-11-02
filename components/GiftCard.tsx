import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Gift } from '../db/storage';

interface GiftCardProps {
  gift: Gift;
  onToggle: () => void;
  onDelete: () => void;
}

export const GiftCard: React.FC<GiftCardProps> = ({ gift, onToggle, onDelete }) => {
  return (
    <View style={styles.card}>
      <View style={styles.content}>
        <TouchableOpacity
          onPress={onToggle}
          style={styles.toggleButton}
          activeOpacity={0.7}
        >
          <View style={[styles.checkbox, gift.is_given ? styles.checkboxChecked : null]}>
            {gift.is_given && (
              <Text style={styles.checkmark}>✓</Text>
            )}
          </View>
          <Text style={[styles.text, gift.is_given ? styles.textDone : null]}>
            {gift.idea}
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={onDelete}
          style={styles.deleteButton}
          activeOpacity={0.7}
        >
          <Text style={styles.deleteText}>Удалить</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: 12,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#f3f4f6',
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  toggleButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  checkbox: {
    width: 20,
    height: 20,
    borderRadius: 4,
    borderWidth: 2,
    borderColor: '#d1d5db',
    marginRight: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxChecked: {
    backgroundColor: '#22c55e',
    borderColor: '#22c55e',
  },
  checkmark: {
    color: '#ffffff',
    fontSize: 12,
  },
  text: {
    flex: 1,
    fontSize: 16,
    color: '#111827',
  },
  textDone: {
    color: '#9ca3af',
    textDecorationLine: 'line-through',
  },
  deleteButton: {
    marginLeft: 12,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  deleteText: {
    color: '#ef4444',
    fontSize: 14,
  },
});
