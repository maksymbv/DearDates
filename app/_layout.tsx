import { Stack } from 'expo-router';
import { useEffect } from 'react';
import { useStore } from '../store/useStore';
import { requestPermissions } from '../utils/notifications';

export default function RootLayout() {
  const loadProfiles = useStore((state) => state.loadProfiles);

  useEffect(() => {
    const initialize = async () => {
      try {
        await requestPermissions();
        await loadProfiles();
      } catch (error) {
        console.error('Initialization error:', error);
      }
    };
    initialize();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return <Stack />;
}
