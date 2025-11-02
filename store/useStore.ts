import { create } from 'zustand';
import { Profile, Gift, getAllProfiles, saveProfile, deleteProfile as deleteProfileStorage, getAllGifts, saveGift, deleteGift as deleteGiftStorage, generateId } from '../db/storage';
import { calculateNextBirthday, daysUntilBirthday } from '../utils/dates';
import { scheduleBirthdayNotification } from '../utils/notifications';

export interface ProfileWithGifts extends Profile {
  gifts: Gift[];
  nextBirthday?: Date;
  daysUntil?: number;
}

interface StoreState {
  profiles: ProfileWithGifts[];
  isLoading: boolean;
  loadProfiles: () => Promise<void>;
  addProfile: (name: string, birthdate: string, relationship?: string, notes?: string) => Promise<void>;
  updateProfile: (id: string, name: string, birthdate: string, relationship?: string, notes?: string) => Promise<void>;
  deleteProfile: (id: string) => Promise<void>;
  addGift: (profileId: string, idea: string) => Promise<void>;
  updateGiftStatus: (giftId: string, isGiven: boolean) => Promise<void>;
  deleteGift: (giftId: string) => Promise<void>;
}

export const useStore = create<StoreState>((set, get) => ({
  profiles: [],
  isLoading: false,

  loadProfiles: async () => {
    set({ isLoading: true });
    try {
      const profiles = await getAllProfiles();
      const allGifts = await getAllGifts();
      
      const profilesWithGifts: ProfileWithGifts[] = profiles.map((profile) => {
        const gifts = allGifts.filter((g) => g.profile_id === profile.id);
        const nextBirthday = calculateNextBirthday(profile.birthdate);
        const daysUntil = daysUntilBirthday(profile.birthdate);
        return {
          ...profile,
          gifts,
          nextBirthday,
          daysUntil,
        };
      });
      
      // Сортировка по ближайшей дате
      profilesWithGifts.sort((a, b) => (a.daysUntil || 999) - (b.daysUntil || 999));
      
      set({ profiles: profilesWithGifts, isLoading: false });
    } catch (error) {
      console.error('Error loading profiles:', error);
      set({ isLoading: false });
    }
  },

  addProfile: async (name: string, birthdate: string, relationship?: string, notes?: string) => {
    try {
      const profile: Profile = {
        id: generateId(),
        name,
        birthdate,
        relationship,
        notes,
        created_at: new Date().toISOString(),
      };
      await saveProfile(profile);
      // Уведомления работают с числовым ID
      try {
        await scheduleBirthdayNotification(Date.parse(profile.id) % 1000000, name, birthdate);
      } catch (e) {
        // Игнорируем ошибки уведомлений
      }
      await get().loadProfiles();
    } catch (error) {
      console.error('Error adding profile:', error);
      throw error;
    }
  },

  updateProfile: async (id: string, name: string, birthdate: string, relationship?: string, notes?: string) => {
    try {
      const profiles = await getAllProfiles();
      const profile = profiles.find((p) => p.id === id);
      if (!profile) throw new Error('Profile not found');
      
      const updated: Profile = {
        ...profile,
        name,
        birthdate,
        relationship,
        notes,
      };
      await saveProfile(updated);
      // Уведомления работают с числовым ID
      try {
        await scheduleBirthdayNotification(Date.parse(id) % 1000000, name, birthdate);
      } catch (e) {
        // Игнорируем ошибки уведомлений
      }
      await get().loadProfiles();
    } catch (error) {
      console.error('Error updating profile:', error);
      throw error;
    }
  },

  deleteProfile: async (id: string) => {
    try {
      await deleteProfileStorage(id);
      await get().loadProfiles();
    } catch (error) {
      console.error('Error deleting profile:', error);
      throw error;
    }
  },

  addGift: async (profileId: string, idea: string) => {
    try {
      const gift: Gift = {
        id: generateId(),
        profile_id: profileId,
        idea,
        is_given: 0,
        created_at: new Date().toISOString(),
      };
      await saveGift(gift);
      await get().loadProfiles();
    } catch (error) {
      console.error('Error adding gift:', error);
      throw error;
    }
  },

  updateGiftStatus: async (giftId: string, isGiven: boolean) => {
    try {
      const allGifts = await getAllGifts();
      const gift = allGifts.find((g) => g.id === giftId);
      if (!gift) throw new Error('Gift not found');
      
      const updated: Gift = {
        ...gift,
        is_given: isGiven ? 1 : 0,
      };
      await saveGift(updated);
      await get().loadProfiles();
    } catch (error) {
      console.error('Error updating gift status:', error);
      throw error;
    }
  },

  deleteGift: async (giftId: string) => {
    try {
      await deleteGiftStorage(giftId);
      await get().loadProfiles();
    } catch (error) {
      console.error('Error deleting gift:', error);
      throw error;
    }
  },
}));
