import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Profile, Gift, getAllProfiles, saveProfile, deleteProfile as deleteProfileStorage, getAllGifts, saveGift, deleteGift as deleteGiftStorage, generateId } from '../db/storage';
import { calculateNextBirthday, daysUntilBirthday } from '../utils/dates';
import { scheduleBirthdayNotification } from '../utils/notifications';

export interface ProfileWithGifts extends Profile {
  gifts: Gift[];
  nextBirthday?: Date;
  daysUntil?: number;
}

interface ProfilesContextType {
  profiles: ProfileWithGifts[];
  isLoading: boolean;
  loadProfiles: () => Promise<void>;
  addProfile: (name: string, birthdate: string, notes?: string) => Promise<void>;
  updateProfile: (id: string, name: string, birthdate: string, notes?: string) => Promise<void>;
  deleteProfile: (id: string) => Promise<void>;
  addGift: (profileId: string, idea: string) => Promise<void>;
  updateGift: (giftId: string, idea: string) => Promise<void>;
  updateGiftStatus: (giftId: string, isGiven: boolean) => Promise<void>;
  deleteGift: (giftId: string) => Promise<void>;
}

const ProfilesContext = createContext<ProfilesContextType | undefined>(undefined);

export const ProfilesProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [profiles, setProfiles] = useState<ProfileWithGifts[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  const loadProfiles = async () => {
    setIsLoading(true);
    try {
      const profilesData = await getAllProfiles();
      const allGifts = await getAllGifts();
      
      const profilesWithGifts: ProfileWithGifts[] = profilesData.map((profile) => {
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
      
      setProfiles(profilesWithGifts);
    } catch (error) {
      console.error('Error loading profiles:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const addProfile = async (name: string, birthdate: string, notes?: string) => {
    try {
      const profile: Profile = {
        id: generateId(),
        name,
        birthdate,
        notes,
        created_at: new Date().toISOString(),
      };
      await saveProfile(profile);
      try {
        await scheduleBirthdayNotification(Date.parse(profile.id) % 1000000, name, birthdate);
      } catch (e) {
        // Игнорируем ошибки уведомлений
      }
      await loadProfiles();
    } catch (error) {
      console.error('Error adding profile:', error);
      throw error;
    }
  };

  const updateProfile = async (id: string, name: string, birthdate: string, notes?: string) => {
    try {
      const profilesData = await getAllProfiles();
      const profile = profilesData.find((p) => p.id === id);
      if (!profile) throw new Error('Profile not found');

      const updated: Profile = {
        ...profile,
        name,
        birthdate,
        notes,
      };
      await saveProfile(updated);
      try {
        await scheduleBirthdayNotification(Date.parse(id) % 1000000, name, birthdate);
      } catch (e) {
        // Игнорируем ошибки уведомлений
      }
      await loadProfiles();
    } catch (error) {
      console.error('Error updating profile:', error);
      throw error;
    }
  };

  const deleteProfile = async (id: string) => {
    try {
      await deleteProfileStorage(id);
      await loadProfiles();
    } catch (error) {
      console.error('Error deleting profile:', error);
      throw error;
    }
  };

  const addGift = async (profileId: string, idea: string) => {
    try {
      const gift: Gift = {
        id: generateId(),
        profile_id: profileId,
        idea,
        is_given: 0,
        created_at: new Date().toISOString(),
      };
      await saveGift(gift);
      await loadProfiles();
    } catch (error) {
      console.error('Error adding gift:', error);
      throw error;
    }
  };

  const updateGift = async (giftId: string, idea: string) => {
    try {
      const allGifts = await getAllGifts();
      const gift = allGifts.find((g) => g.id === giftId);
      if (!gift) throw new Error('Gift not found');

      const updated: Gift = {
        ...gift,
        idea,
      };
      await saveGift(updated);
      await loadProfiles();
    } catch (error) {
      console.error('Error updating gift:', error);
      throw error;
    }
  };

  const updateGiftStatus = async (giftId: string, isGiven: boolean) => {
    try {
      const allGifts = await getAllGifts();
      const gift = allGifts.find((g) => g.id === giftId);
      if (!gift) throw new Error('Gift not found');

      const updated: Gift = {
        ...gift,
        is_given: isGiven ? 1 : 0,
      };
      await saveGift(updated);
      await loadProfiles();
    } catch (error) {
      console.error('Error updating gift status:', error);
      throw error;
    }
  };

  const deleteGift = async (giftId: string) => {
    try {
      await deleteGiftStorage(giftId);
      await loadProfiles();
    } catch (error) {
      console.error('Error deleting gift:', error);
      throw error;
    }
  };

  useEffect(() => {
    loadProfiles();
  }, []);

  return (
    <ProfilesContext.Provider
      value={{
        profiles,
        isLoading,
        loadProfiles,
        addProfile,
        updateProfile,
        deleteProfile,
        addGift,
        updateGift,
        updateGiftStatus,
        deleteGift,
      }}
    >
      {children}
    </ProfilesContext.Provider>
  );
};

export const useProfiles = () => {
  const context = useContext(ProfilesContext);
  if (context === undefined) {
    throw new Error('useProfiles must be used within a ProfilesProvider');
  }
  return context;
};

