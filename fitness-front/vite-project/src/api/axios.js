import axios from 'axios';
const API_BASE_URL = 'http://a203b377663d04070b2654e130060304-174660127.eu-west-1.elb.amazonaws.com:8080/api';
const instance = axios.create({
    baseURL: API_BASE_URL,
    timeout: 10000,
    headers: {
        'Content-Type': 'application/json',
    },
});

instance.interceptors.request.use(config => {
    const token = localStorage.getItem('token');
    const userId = localStorage.getItem('userId');
    
    console.log('Adding headers - UserID:', userId, 'Type:', typeof userId);
    
    if (token) {
        config.headers['Authorization'] = `Bearer ${token}`;
    }
    if (userId && typeof userId === 'string') {
        config.headers['X-USER-ID'] = userId;
    }
    return config;
});

export default instance;
export const activities = () => instance.get('/activities');
export const addActivity = (activityData) => instance.post('/activities', activityData);
export const getActivityDetail = (id) => instance.get(`/recommendations/activity/${id}`);