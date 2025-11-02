import React from "react";
import { View, Text, ScrollView, StyleSheet } from "react-native";

export default function SettingsScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Настройки</Text>
        <Text style={styles.sectionDescription}>
          Здесь будут настройки приложения
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F8F5F2",
  },
  content: {
    padding: 20,
  },
  section: {
    backgroundColor: "#ffffff",
    borderRadius: 16,
    padding: 20,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: "#E8E0DB",
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: "600",
    color: "#2E2E2E",
    marginBottom: 8,
  },
  sectionDescription: {
    fontSize: 16,
    color: "#2E2E2E",
    opacity: 0.7,
  },
});

