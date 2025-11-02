import AsyncStorage from '@react-native-async-storage/async-storage';

export interface Profile {
  id: string;
  name: string;
  birthdate: string; // YYYY-MM-DD
  notes?: string;
  created_at: string;
}

export interface Gift {
  id: string;
  profile_id: string;
  idea: string;
  is_given: number; // 0 or 1 (boolean)
  created_at: string;
}

const STORAGE_KEYS = {
  PROFILES: '@deardates:profiles',
  GIFTS: '@deardates:gifts',
};

// Профили
export const getAllProfiles = async (): Promise<Profile[]> => {
  try {
    const data = await AsyncStorage.getItem(STORAGE_KEYS.PROFILES);
    return data ? JSON.parse(data) : [];
  } catch (error) {
    console.error('Error getting profiles:', error);
    return [];
  }
};

export const saveProfile = async (profile: Profile): Promise<void> => {
  try {
    const profiles = await getAllProfiles();
    const index = profiles.findIndex((p) => p.id === profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.push(profile);
    }
    await AsyncStorage.setItem(STORAGE_KEYS.PROFILES, JSON.stringify(profiles));
  } catch (error) {
    console.error('Error saving profile:', error);
    throw error;
  }
};

export const deleteProfile = async (id: string): Promise<void> => {
  try {
    const profiles = await getAllProfiles();
    const filtered = profiles.filter((p) => p.id !== id);
    await AsyncStorage.setItem(STORAGE_KEYS.PROFILES, JSON.stringify(filtered));
    // Также удаляем подарки этого профиля
    const gifts = await getAllGifts();
    const filteredGifts = gifts.filter((g) => g.profile_id !== id);
    await AsyncStorage.setItem(STORAGE_KEYS.GIFTS, JSON.stringify(filteredGifts));
  } catch (error) {
    console.error('Error deleting profile:', error);
    throw error;
  }
};

// Подарки
export const getAllGifts = async (): Promise<Gift[]> => {
  try {
    const data = await AsyncStorage.getItem(STORAGE_KEYS.GIFTS);
    return data ? JSON.parse(data) : [];
  } catch (error) {
    console.error('Error getting gifts:', error);
    return [];
  }
};

export const getGiftsByProfileId = async (profileId: string): Promise<Gift[]> => {
  try {
    const gifts = await getAllGifts();
    return gifts.filter((g) => g.profile_id === profileId);
  } catch (error) {
    console.error('Error getting gifts by profile:', error);
    return [];
  }
};

export const saveGift = async (gift: Gift): Promise<void> => {
  try {
    const gifts = await getAllGifts();
    const index = gifts.findIndex((g) => g.id === gift.id);
    if (index >= 0) {
      gifts[index] = gift;
    } else {
      gifts.push(gift);
    }
    await AsyncStorage.setItem(STORAGE_KEYS.GIFTS, JSON.stringify(gifts));
  } catch (error) {
    console.error('Error saving gift:', error);
    throw error;
  }
};

export const deleteGift = async (id: string): Promise<void> => {
  try {
    const gifts = await getAllGifts();
    const filtered = gifts.filter((g) => g.id !== id);
    await AsyncStorage.setItem(STORAGE_KEYS.GIFTS, JSON.stringify(filtered));
  } catch (error) {
    console.error('Error deleting gift:', error);
    throw error;
  }
};

// Утилиты
export const generateId = (): string => {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
};

