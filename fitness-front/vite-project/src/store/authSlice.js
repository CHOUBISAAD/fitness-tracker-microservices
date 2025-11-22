import { createSlice } from "@reduxjs/toolkit";

// Helper function to safely parse JSON from localStorage
const getFromLocalStorage = (key) => {
  try {
    const item = localStorage.getItem(key);
    if (item && item !== "undefined" && item !== "null") {
      return JSON.parse(item);
    }
    return null;
  } catch (error) {
    console.error(`Error parsing localStorage key "${key}":`, error);
    return null;
  }
};

const authSlice = createSlice({
  name: "auth",
  initialState: {
    user: getFromLocalStorage("user"),
    token: localStorage.getItem("token") || null,
    userId: localStorage.getItem("userId") || null,
},
  reducers: {
    setCredentials: (state, action) => {
      state.user = action.payload.user;
      state.token = action.payload.token;
      
      // Only set userId if user data is available and has a sub property
      if (action.payload.user && action.payload.user.sub) {
        state.userId = action.payload.user.sub;
        localStorage.setItem("userId", action.payload.user.sub);
      }

      // Safely store user data
      if (action.payload.user) {
        localStorage.setItem("user", JSON.stringify(action.payload.user));
      }
      
      // Safely store token
      if (action.payload.token) {
        localStorage.setItem("token", action.payload.token);
      }
    },

    logout: (state) => {
      state.user = null;
      state.token = null;
      state.userId = null;
      localStorage.removeItem("user");
      localStorage.removeItem("token");
      localStorage.removeItem("userId");
    },
  },
});

export const { setCredentials, /* login, */ logout } = authSlice.actions;
export default authSlice.reducer;