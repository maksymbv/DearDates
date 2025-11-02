import * as SQLite from 'expo-sqlite';

let db: SQLite.SQLiteDatabase | null = null;

export interface Profile {
  id: number;
  name: string;
  birthdate: string; // YYYY-MM-DD
  notes?: string;
  created_at: string;
}

export interface Gift {
  id: number;
  profile_id: number;
  idea: string;
  is_given: number; // 0 or 1 (SQLite boolean)
  created_at: string;
}

const getDatabase = async (): Promise<SQLite.SQLiteDatabase> => {
  if (!db) {
    db = await SQLite.openDatabaseAsync('deardates.db');
  }
  return db;
};

export const initDatabase = async (): Promise<void> => {
  try {
    const database = await getDatabase();
    
    // Create profiles table
    await database.execAsync(`
      CREATE TABLE IF NOT EXISTS profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birthdate TEXT NOT NULL,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create gifts table
    await database.execAsync(`
      CREATE TABLE IF NOT EXISTS gifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        idea TEXT NOT NULL,
        is_given INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
      );
    `);

    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Database initialization error:', error);
    throw error;
  }
};

export const addProfile = async (
  name: string,
  birthdate: string,
  notes?: string
): Promise<number> => {
  try {
    const database = await getDatabase();
    const result = await database.runAsync(
      'INSERT INTO profiles (name, birthdate, notes) VALUES (?, ?, ?);',
      [name, birthdate, notes || null]
    );
    return result.lastInsertRowId;
  } catch (error) {
    console.error('Error adding profile:', error);
    throw error;
  }
};

export const updateProfile = async (
  id: number,
  name: string,
  birthdate: string,
  notes?: string
): Promise<void> => {
  try {
    const database = await getDatabase();
    await database.runAsync(
      'UPDATE profiles SET name = ?, birthdate = ?, notes = ? WHERE id = ?;',
      [name, birthdate, notes || null, id]
    );
  } catch (error) {
    console.error('Error updating profile:', error);
    throw error;
  }
};

export const deleteProfile = async (id: number): Promise<void> => {
  try {
    const database = await getDatabase();
    await database.runAsync('DELETE FROM profiles WHERE id = ?;', [id]);
  } catch (error) {
    console.error('Error deleting profile:', error);
    throw error;
  }
};

export const getAllProfiles = async (): Promise<Profile[]> => {
  try {
    const database = await getDatabase();
    const result = await database.getAllAsync<Profile>(
      'SELECT * FROM profiles ORDER BY created_at DESC;'
    );
    return result;
  } catch (error) {
    console.error('Error getting profiles:', error);
    throw error;
  }
};

export const getProfileById = async (id: number): Promise<Profile | null> => {
  try {
    const database = await getDatabase();
    const result = await database.getFirstAsync<Profile>(
      'SELECT * FROM profiles WHERE id = ?;',
      [id]
    );
    return result || null;
  } catch (error) {
    console.error('Error getting profile:', error);
    throw error;
  }
};

export const addGift = async (
  profileId: number,
  idea: string
): Promise<number> => {
  try {
    const database = await getDatabase();
    const result = await database.runAsync(
      'INSERT INTO gifts (profile_id, idea) VALUES (?, ?);',
      [profileId, idea]
    );
    return result.lastInsertRowId;
  } catch (error) {
    console.error('Error adding gift:', error);
    throw error;
  }
};

export const updateGiftStatus = async (
  id: number,
  isGiven: boolean
): Promise<void> => {
  try {
    const database = await getDatabase();
    await database.runAsync(
      'UPDATE gifts SET is_given = ? WHERE id = ?;',
      [isGiven ? 1 : 0, id]
    );
  } catch (error) {
    console.error('Error updating gift status:', error);
    throw error;
  }
};

export const deleteGift = async (id: number): Promise<void> => {
  try {
    const database = await getDatabase();
    await database.runAsync('DELETE FROM gifts WHERE id = ?;', [id]);
  } catch (error) {
    console.error('Error deleting gift:', error);
    throw error;
  }
};

export const getGiftsByProfileId = async (profileId: number): Promise<Gift[]> => {
  try {
    const database = await getDatabase();
    const result = await database.getAllAsync<Gift>(
      'SELECT * FROM gifts WHERE profile_id = ? ORDER BY created_at DESC;',
      [profileId]
    );
    return result;
  } catch (error) {
    console.error('Error getting gifts:', error);
    throw error;
  }
};
