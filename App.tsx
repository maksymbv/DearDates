import React, { useEffect } from 'react';
import { ProfilesProvider } from './context/ProfilesContext';
import { AppNavigator } from './navigation/AppNavigator';
import { requestPermissions } from './utils/notifications';

export default function App() {
  useEffect(() => {
    const initialize = async () => {
      try {
        await requestPermissions();
      } catch (error) {
        console.error('Initialization error:', error);
      }
    };
    initialize();
  }, []);

  return (
    <ProfilesProvider>
      <AppNavigator />
    </ProfilesProvider>
  );
}
