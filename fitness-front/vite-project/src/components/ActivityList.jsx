import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import Stack from '@mui/material/Stack'
import { Card, CardContent, Typography } from '@mui/material'
import {activities} from '../api/axios';

function ActivityList() {
  // Use explicit names to avoid any accidental shadowing like `activities()`
  const [activityList, setActivityList] = React.useState([]);

  const fetchActivities = async () => {
    try {
      const response = await activities();
      const data = response?.data;
      // Support both array and paginated shapes (e.g., { content: [...] })
      const list = Array.isArray(data) ? data : Array.isArray(data?.content) ? data.content : [];
      setActivityList(list);
    } catch (error) {
      const status = error?.response?.status;
      console.error('Error fetching activities:', status ? `${status} ${error.response.statusText}` : error);
    }
  }

  useEffect(() => {
    fetchActivities();
  }, []);

  const navigate = useNavigate();
  return (

  <>
  <Stack spacing={2}>
  {activityList.map((activity) => (
      <Card key={activity.id} sx={{ mb: 2 }} onClick={() => navigate(`/activities/${activity.id}`)}>
        <CardContent>
          <Typography variant="h6">Type :{activity.type}</Typography>
          <Typography variant="body2">Duration: {activity.duration} minutes</Typography>
          <Typography variant="body2">Calories Burned: {activity.caloriesBurned}</Typography>
        </CardContent>
      </Card>
    ))}
  </Stack>
  
  </>
  )
}

export default ActivityList