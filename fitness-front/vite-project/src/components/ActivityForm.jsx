import Button from '@mui/material/Button';
import FormControl from '@mui/material/FormControl';
import TextField from '@mui/material/TextField';
import React from 'react'
import Box from '@mui/material/Box';
import InputLabel from '@mui/material/InputLabel';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import { addActivity } from '../api/axios';


function ActivityForm({onActivityAdded}) {

    const [activity,setActivity]=React.useState({
        activityType:'RUNNING',
        duration:'',
        caloriesBurned:'',
        additionalMetrics:{

        }
    });

    const handleSubmit = async (e) => {
        e.preventDefault();
        try{
           await addActivity(activity);
            onActivityAdded();
            setActivity({
                activityType:'RUNNING',
                duration:'',
                caloriesBurned:'',
                additionalMetrics:{
                    heartRate:'',
                    distance:'',
                    elevationGain:''
                }
            });
        } catch (error) {
            console.error('Error adding activity:', error);
        }
    }

  return (
    <>
      <Box component="form" onSubmit={handleSubmit} sx={{ mb: 4 }}>
        <FormControl fullWidth sx={{ mb: 2 }}>
          <InputLabel id="activity-type-label">Activity Type</InputLabel>
          <Select
            labelId="activity-type-label"
            id="activity-type"
            label="Activity Type"
            value={activity.activityType}
            onChange={(e) => setActivity({ ...activity, activityType: e.target.value })}
          >
            <MenuItem value="RUNNING">RUNNING</MenuItem>
            <MenuItem value="CYCLING">CYCLING</MenuItem>
            <MenuItem value="SWIMMING">SWIMMING</MenuItem>
          </Select>
        </FormControl>

        <TextField
          fullWidth
          label="Duration (minutes)"
          type="number"
          value={activity.duration}
          onChange={(e) => setActivity({ ...activity, duration: e.target.value })}
          sx={{ mb: 2 }}
        />

        <TextField
          fullWidth
          label="Calories Burned"
          type="number"
          value={activity.caloriesBurned}
          onChange={(e) => setActivity({ ...activity, caloriesBurned: e.target.value })}
          sx={{ mb: 2 }}
        />

        <Button type="submit" variant="contained" color="primary">
          Add Activity
        </Button>
      </Box>
    </>
  )
}

export default ActivityForm