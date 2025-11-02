import React, { useState, useLayoutEffect } from 'react';
import { View, ScrollView, TouchableOpacity, RefreshControl, StyleSheet, Text } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Plus, Settings } from 'lucide-react-native';
import { useProfiles } from '../context/ProfilesContext';
import { ProfileCard } from '../components/ProfileCard';
import { EmptyState } from '../components/EmptyState';
import { RootStackParamList } from '../navigation/AppNavigator';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

export default function HomeScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { profiles, loadProfiles } = useProfiles();
  const [refreshing, setRefreshing] = useState(false);

  useLayoutEffect(() => {
    navigation.setOptions({
      headerLeft: () => (
        <View style={styles.headerLeft}>
          <Text style={styles.headerTitle}>Dear Dates</Text>
        </View>
      ),
      headerRight: () => (
        <TouchableOpacity
          onPress={() => navigation.navigate('Settings')}
          style={styles.settingsButton}
          activeOpacity={0.7}
        >
          <Settings size={22} color="#2E2E2E" />
        </TouchableOpacity>
      ),
    });
  }, [navigation]);

  const handleRefresh = async () => {
    setRefreshing(true);
    try {
      await loadProfiles();
    } finally {
      setRefreshing(false);
    }
  };

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
        }
      >
        {profiles.length === 0 && !refreshing ? (
          <EmptyState
            title="Пока нет дней рождения"
            message="Добавьте первый профиль, чтобы начать отслеживать дни рождения и идеи подарков"
          />
        ) : (
          profiles.map((profile) => (
            <ProfileCard
              key={profile.id}
              profile={profile}
              onPress={() => navigation.navigate('Profile', { id: profile.id })}
            />
          ))
        )}
      </ScrollView>

      <TouchableOpacity
        onPress={() => navigation.navigate('AddProfile')}
        style={styles.fab}
        activeOpacity={0.8}
      >
        <Plus size={28} color="white" />
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F5F2',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 16,
    paddingTop: 16,
  },
  fab: {
    position: 'absolute',
    bottom: 40,
    right: 24,
    width: 56,
    height: 56,
    backgroundColor: '#D68A9E',
    borderRadius: 28,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  settingsButton: {
    paddingVertical: 10,
    paddingHorizontal: 16,
    marginRight: 4,
  },
  headerLeft: {
    paddingLeft: 4,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#D68A9E',
  },
});

