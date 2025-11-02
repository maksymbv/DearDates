import React, { useMemo } from 'react';
import { View, Text } from 'react-native';

interface AnimalAvatarProps {
  seed?: string | number;
  size?: number;
}

// Список эмодзи животных
const animals = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐙', '🦄', '🐝', '🐢', '🐠', '🐬', '🐳', '🐘', '🦒', '🦓', '🐴', '🦋', '🐛', '🐞', '🐜'];

// Список цветов (аналогично react-animals)
const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA15E', '#F7B267', '#F79D65', '#F4845F', '#E76F51'];

// Функция для генерации стабильного "рандомного" значения на основе seed
const seededRandom = (seed: string | number) => {
  const str = String(seed);
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32bit integer
  }
  return Math.abs(hash);
};

export const AnimalAvatar: React.FC<AnimalAvatarProps> = ({ seed = 'default', size = 56 }) => {
  const { animal, color } = useMemo(() => {
    const hash = seededRandom(seed);
    const animalIndex = hash % animals.length;
    const colorIndex = hash % colors.length;
    
    return {
      animal: animals[animalIndex],
      color: colors[colorIndex],
    };
  }, [seed]);

  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: size / 2,
        backgroundColor: color,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <Text style={{ fontSize: size * 0.5 }}>
        {animal}
      </Text>
    </View>
  );
};

