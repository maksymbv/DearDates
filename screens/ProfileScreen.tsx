import React, { useEffect, useState, useLayoutEffect } from "react";
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
  StyleSheet,
  Platform,
  Modal,
} from "react-native";
import { useNavigation, useRoute, RouteProp } from "@react-navigation/native";
import { NativeStackNavigationProp } from "@react-navigation/native-stack";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Pencil, Trash, Plus, Check, Cake, Gift, X } from "lucide-react-native";
import { useProfiles, ProfileWithGifts } from "../context/ProfilesContext";
import { formatDate, getAge } from "../utils/dates";
import { RootStackParamList } from "../navigation/AppNavigator";
import { AnimalAvatar } from "../components/AnimalAvatar";

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;
type ProfileRouteProp = RouteProp<RootStackParamList, "Profile">;

export default function ProfileScreen() {
  const navigation = useNavigation<NavigationProp>();
  const route = useRoute<ProfileRouteProp>();
  const { id: profileId } = route.params;
  const {
    profiles,
    deleteProfile,
    addGift,
    updateGift,
    updateGiftStatus,
    deleteGift,
  } = useProfiles();
  const insets = useSafeAreaInsets();

  const [profile, setProfile] = useState<ProfileWithGifts | null>(null);
  const [editingGift, setEditingGift] = useState<{
    id: string;
    idea: string;
  } | null>(null);
  const [editGiftText, setEditGiftText] = useState("");
  const [addingGift, setAddingGift] = useState(false);
  const [newGiftText, setNewGiftText] = useState("");

  useEffect(() => {
    const foundProfile = profiles.find((p) => p.id === profileId);
    if (foundProfile) {
      setProfile(foundProfile);
    }
  }, [profiles, profileId]);

  const handleDelete = () => {
    Alert.alert(
      "Удалить профиль",
      "Вы уверены, что хотите удалить этот профиль?",
      [
        { text: "Отмена", style: "cancel" },
        {
          text: "Удалить",
          style: "destructive",
          onPress: async () => {
            try {
              await deleteProfile(profileId);
              navigation.goBack();
            } catch (error) {
              Alert.alert("Ошибка", "Не удалось удалить профиль");
            }
          },
        },
      ]
    );
  };

  useLayoutEffect(() => {
    navigation.setOptions({
      headerRight: () => (
        <View style={styles.headerActions}>
          <TouchableOpacity
            onPress={() =>
              navigation.navigate("EditProfile", { id: profileId })
            }
            style={[styles.headerActionButton, styles.editActionButton]}
            activeOpacity={0.7}
          >
            <Pencil size={20} color="#2E2E2E" />
          </TouchableOpacity>
          <TouchableOpacity
            onPress={handleDelete}
            style={styles.headerActionButton}
            activeOpacity={0.7}
          >
            <Trash size={20} color="#2E2E2E" />
          </TouchableOpacity>
        </View>
      ),
    });
  }, [navigation, profileId, handleDelete]);

  const handleSaveNewGift = async () => {
    if (!newGiftText.trim()) {
      Alert.alert("Ошибка", "Пожалуйста, введите идею подарка");
      return;
    }

    try {
      await addGift(profileId, newGiftText.trim());
      setNewGiftText("");
      setAddingGift(false);
    } catch (error) {
      Alert.alert("Ошибка", "Не удалось добавить подарок");
      console.error(error);
    }
  };

  if (!profile) {
    return (
      <View style={styles.notFound}>
        <Text style={styles.notFoundText}>Профиль не найден</Text>
      </View>
    );
  }

  const age = getAge(profile.birthdate);
  const pastGifts = profile.gifts.filter((g) => g.is_given === 1);
  const futureGifts = profile.gifts.filter((g) => g.is_given === 0);

  const truncateText = (text: string, maxLength: number = 100) => {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength) + "...";
  };

  // Группировка подаренных подарков по годам
  const giftsByYear = pastGifts.reduce((acc, gift) => {
    const year = new Date(gift.created_at).getFullYear();
    if (!acc[year]) {
      acc[year] = [];
    }
    acc[year].push(gift);
    return acc;
  }, {} as Record<number, typeof pastGifts>);

  const sortedYears = Object.keys(giftsByYear)
    .map(Number)
    .sort((a, b) => b - a); // От нового к старому

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.profileCard}>
        <View style={styles.profileHeader}>
          <AnimalAvatar seed={profile.id} size={80} />
          <View style={styles.profileInfo}>
            <Text style={styles.name}>{profile.name}</Text>
            <View style={styles.dateContainer}>
              <Cake size={22} color="#2E2E2E" style={styles.cakeIcon} />
              <Text style={styles.date}>
                {formatDate(profile.birthdate)} ({age} лет)
              </Text>
            </View>
          </View>
          </View>
        
        {profile.notes && (
          <>
            <View style={styles.notesDivider} />
            <Text style={styles.notes}>{profile.notes}</Text>
          </>
        )}
      </View>

      <View style={styles.giftsCard}>
        <TouchableOpacity
          onPress={() => {
            setNewGiftText("");
            setAddingGift(true);
          }}
          style={styles.addGiftButton}
          activeOpacity={0.7}
        >
          <Gift size={22} color="#ffffff" />
          <Text style={styles.addGiftButtonText}>Добавить идею</Text>
        </TouchableOpacity>

        {futureGifts.length > 0 && (
          <View style={styles.giftSection}>
            <Text style={styles.giftSectionTitle}>Запланированные</Text>
            {futureGifts.map((gift, index) => (
              <TouchableOpacity
                key={gift.id}
                style={[
                  styles.giftItem,
                  index === futureGifts.length - 1 && styles.lastGiftItem,
                ]}
                onPress={() => {
                  setEditGiftText(gift.idea);
                  setEditingGift({ id: gift.id, idea: gift.idea });
                }}
                activeOpacity={0.7}
              >
                <Text style={styles.giftText}>{truncateText(gift.idea)}</Text>
                <TouchableOpacity
                  onPress={(e) => {
                    e.stopPropagation();
                    updateGiftStatus(gift.id, true);
                  }}
                  style={styles.giftActionButton}
                  activeOpacity={0.7}
                >
                  <Check size={18} color="#D68A9E" />
                </TouchableOpacity>
              </TouchableOpacity>
            ))}
          </View>
        )}

        {pastGifts.length > 0 && (
          <View style={styles.giftSection}>
            <Text style={styles.giftSectionTitle}>Уже подарено</Text>
            {sortedYears.map((year, yearIndex) => (
              <View
                key={year}
                style={[
                  styles.yearGroup,
                  yearIndex === sortedYears.length - 1 && styles.lastYearGroup,
                ]}
              >
                <View style={styles.yearHeader}>
                  <Text style={styles.yearTitle}>{year}</Text>
                  <View style={styles.yearDivider} />
                </View>
                {giftsByYear[year].map((gift, giftIndex) => {
                  const isLastGiftInYear =
                    giftIndex === giftsByYear[year].length - 1;
                  const isLastYear = yearIndex === sortedYears.length - 1;
                  return (
                    <TouchableOpacity
                      key={gift.id}
                      style={[
                        styles.giftItem,
                        isLastGiftInYear &&
                          !isLastYear &&
                          styles.lastGiftInYear,
                        isLastGiftInYear && isLastYear && styles.lastGiftItem,
                      ]}
                      onPress={() => {
                        setEditGiftText(gift.idea);
                        setEditingGift({ id: gift.id, idea: gift.idea });
                      }}
                      activeOpacity={0.7}
                    >
                      <Text style={styles.giftText}>
                        {truncateText(gift.idea)}
                      </Text>
                    </TouchableOpacity>
                  );
                })}
              </View>
            ))}
          </View>
        )}

        {profile.gifts.length === 0 && (
          <Text style={styles.emptyGifts}>
            Пока нет идей подарков. Добавьте первую!
          </Text>
        )}
      </View>

      <Modal
        visible={editingGift !== null || addingGift}
        transparent={true}
        animationType="slide"
        onRequestClose={() => {
          if (editingGift) {
            setEditingGift(null);
            setEditGiftText("");
          }
          if (addingGift) {
            setAddingGift(false);
            setNewGiftText("");
          }
        }}
      >
        <TouchableOpacity
          style={styles.modalOverlay}
          activeOpacity={1}
          onPress={() => {
            if (editingGift) {
              setEditingGift(null);
              setEditGiftText("");
            }
            if (addingGift) {
              setAddingGift(false);
              setNewGiftText("");
            }
          }}
        >
          <View
            style={[
              styles.modalContent,
              { marginTop: insets.top, marginBottom: insets.bottom },
            ]}
            onStartShouldSetResponder={() => true}
          >
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>
                {addingGift ? "Добавить подарок" : "Редактировать подарок"}
              </Text>
              {editingGift && (
                <TouchableOpacity
                  onPress={() => {
                    Alert.alert("Удалить подарок", "Вы уверены?", [
                      { text: "Отмена", style: "cancel" },
                      {
                        text: "Удалить",
                        style: "destructive",
                        onPress: async () => {
                          try {
                            await deleteGift(editingGift.id);
                            setEditingGift(null);
                            setEditGiftText("");
                          } catch (error) {
                            Alert.alert("Ошибка", "Не удалось удалить подарок");
                          }
                        },
                      },
                    ]);
                  }}
                  style={styles.modalDeleteButton}
                  activeOpacity={0.7}
                >
                  <Trash size={20} color="#D68A9E" />
                </TouchableOpacity>
              )}
            </View>
            <TextInput
              value={addingGift ? newGiftText : editGiftText}
              onChangeText={(text) => {
                if (addingGift) {
                  setNewGiftText(text);
                } else {
                  setEditGiftText(text);
                }
              }}
              placeholder="Введите идею подарка..."
              placeholderTextColor="#2E2E2E"
              style={styles.modalInput}
              multiline
              autoFocus
            />
            <View style={styles.modalActions}>
              <TouchableOpacity
                onPress={() => {
                  if (editingGift) {
                    setEditingGift(null);
                    setEditGiftText("");
                  }
                  if (addingGift) {
                    setAddingGift(false);
                    setNewGiftText("");
                  }
                }}
                style={[styles.modalButton, styles.modalCancelButton]}
                activeOpacity={0.7}
              >
                <X size={18} color="#2E2E2E" />
                <Text style={styles.modalCancelText}>Отмена</Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={async () => {
                  if (addingGift) {
                    await handleSaveNewGift();
                  } else if (editGiftText.trim() && editingGift) {
                    try {
                      await updateGift(editingGift.id, editGiftText.trim());
                      setEditingGift(null);
                      setEditGiftText("");
                    } catch (error) {
                      Alert.alert("Ошибка", "Не удалось обновить подарок");
                    }
                  }
                }}
                style={[styles.modalButton, styles.modalSaveButton]}
                activeOpacity={0.7}
              >
                <Check size={18} color="#ffffff" />
                <Text style={styles.modalSaveText}>Сохранить</Text>
              </TouchableOpacity>
            </View>
          </View>
        </TouchableOpacity>
      </Modal>
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
    paddingTop: 20,
    paddingBottom: 20,
  },
  notFound: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  notFoundText: {
    color: "#2E2E2E",
    opacity: 0.6,
  },
  profileCard: {
    backgroundColor: "#ffffff",
    borderRadius: 16,
    padding: 28,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: "#E8E0DB",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 2,
  },
  profileHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    marginBottom: 8,
  },
  profileInfo: {
    flex: 1,
  },
  name: {
    fontSize: 24,
    fontWeight: "700",
    color: "#2E2E2E",
    marginBottom: 8,
  },
  dateContainer: {
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 6,
  },
  cakeIcon: {
    opacity: 0.8,
  },
  date: {
    fontSize: 18,
    color: "#2E2E2E",
    opacity: 0.8,
  },
  notesDivider: {
    height: 1,
    backgroundColor: "#E8E0DB",
    marginTop: 8,
    marginBottom: 12,
  },
  notes: {
    fontSize: 16,
    color: "#2E2E2E",
    opacity: 0.8,
  },
  headerActions: {
    flexDirection: "row",
    gap: 8,
    alignItems: "center",
  },
  headerActionButton: {
    paddingVertical: 10,
    paddingHorizontal: 16,
  },
  editActionButton: {
    marginRight: 4,
  },
  actionButtonText: {
    color: "#ffffff",
    fontWeight: "500",
  },
  giftsCard: {
    backgroundColor: "#ffffff",
    borderRadius: 16,
    padding: 20,
    marginTop: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: "#E8E0DB",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#2E2E2E",
    marginBottom: 12,
  },
  addGiftButton: {
    backgroundColor: "#D68A9E",
    borderRadius: 12,
    paddingVertical: 14,
    paddingHorizontal: 16,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    marginBottom: 16,
  },
  addGiftButtonText: {
    color: "#ffffff",
    fontSize: 16,
    fontWeight: "500",
  },
  giftSection: {
    marginBottom: 0,
    marginTop: 16,
  },
  giftSectionTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: "#2E2E2E",
    marginBottom: 12,
    marginTop: 8,
  },
  yearGroup: {
    marginBottom: 16,
  },
  yearHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 8,
    marginTop: 0,
    gap: 8,
  },
  yearTitle: {
    fontSize: 14,
    fontWeight: "600",
    color: "#2E2E2E",
    opacity: 0.8,
  },
  yearDivider: {
    flex: 1,
    height: 1,
    backgroundColor: "#E8E0DB",
  },
  giftItem: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "#F8F5F2",
    borderRadius: 12,
    padding: 12,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: "#E8E0DB",
  },
  lastGiftItem: {
    marginBottom: 0,
  },
  lastGiftInYear: {
    marginBottom: 8,
  },
  lastYearGroup: {
    marginBottom: 0,
  },
  giftText: {
    flex: 1,
    fontSize: 16,
    color: "#2E2E2E",
  },
  giftTextDone: {
    color: "#2E2E2E",
    opacity: 0.5,
    textDecorationLine: "line-through",
  },
  giftActions: {
    flexDirection: "row",
    gap: 8,
  },
  giftActionButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: "#F8F5F2",
    borderRadius: 8,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "#E8E0DB",
  },
  deleteGiftButton: {
    backgroundColor: "#F8F5F2",
  },
  emptyGifts: {
    color: "#2E2E2E",
    opacity: 0.5,
    fontSize: 14,
    textAlign: "center",
    paddingVertical: 16,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    justifyContent: "center",
    alignItems: "center",
  },
  modalContent: {
    backgroundColor: "#ffffff",
    borderRadius: 24,
    padding: 24,
    width: "90%",
    height: "50%",
    maxHeight: "90%",
    borderWidth: 1,
    borderColor: "#E8E0DB",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  modalHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 16,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#2E2E2E",
    flex: 1,
  },
  modalDeleteButton: {
    padding: 8,
    borderRadius: 8,
    backgroundColor: "#F8F5F2",
  },
  modalInput: {
    borderWidth: 1,
    borderColor: "#E8E0DB",
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: "#F8F5F2",
    textAlignVertical: "top",
    marginBottom: 20,
    flex: 1,
    minHeight: 0,
  },
  modalActions: {
    flexDirection: "row",
    gap: 12,
  },
  modalButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 12,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
  },
  modalCancelButton: {
    backgroundColor: "#F8F5F2",
    borderWidth: 1,
    borderColor: "#E8E0DB",
  },
  modalCancelText: {
    color: "#2E2E2E",
    fontSize: 16,
    fontWeight: "500",
  },
  modalSaveButton: {
    backgroundColor: "#D68A9E",
  },
  modalSaveText: {
    color: "#ffffff",
    fontSize: 16,
    fontWeight: "500",
  },
});
