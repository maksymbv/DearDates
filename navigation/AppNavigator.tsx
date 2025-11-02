import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from '../screens/HomeScreen';
import AddProfileScreen from '../screens/AddProfileScreen';
import EditProfileScreen from '../screens/EditProfileScreen';
import ProfileScreen from '../screens/ProfileScreen';
import SettingsScreen from '../screens/SettingsScreen';

export type RootStackParamList = {
  Home: undefined;
  AddProfile: undefined;
  EditProfile: { id: string };
  Profile: { id: string };
  Settings: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: true,
          headerStyle: {
            backgroundColor: '#F8F5F2',
          },
          headerTintColor: '#2E2E2E',
          headerTitleStyle: {
            fontWeight: '600',
          },
          headerBackTitle: 'Назад',
        }}
      >
        <Stack.Screen 
          name="Home" 
          component={HomeScreen}
          options={{ title: '' }}
        />
        <Stack.Screen 
          name="AddProfile" 
          component={AddProfileScreen}
          options={{ 
            title: 'Добавить профиль'
          }}
        />
        <Stack.Screen 
          name="EditProfile" 
          component={EditProfileScreen}
          options={{ 
            title: 'Редактировать профиль'
          }}
        />
        <Stack.Screen 
          name="Profile" 
          component={ProfileScreen}
          options={{ 
            title: ''
          }}
        />
        <Stack.Screen 
          name="Settings" 
          component={SettingsScreen}
          options={{ 
            title: 'Настройки'
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

