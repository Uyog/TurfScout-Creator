import React, { useState, useEffect, ChangeEvent, useRef } from 'react';
import { IonContent, IonPage, IonHeader, IonToolbar, IonButtons, IonBackButton } from '@ionic/react';
import MyButton from '../components/Button';
import { FaCamera } from 'react-icons/fa';

const ProfilePage: React.FC = () => {
  const [user, setUser] = useState<{ id: number; name: string; email: string; profile_picture: string | null } | null>(null);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    fetchCurrentUser();
  }, []);

  const fetchCurrentUser = async () => {
    try {
      const response = await fetch('http://127.0.0.1:8000/api/user', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        const userData = await response.json();
        setUser(userData);
      } else {
        console.error('Failed to fetch user data:', response.statusText);
      }
    } catch (error) {
      console.error('Error fetching user data:', error);
    }
  };

  const handleUpdateProfile = async () => {
    const newName = prompt('Enter new name:') || '';
    try {
      const response = await fetch(`http://127.0.0.1:8000/api/user/${user?.id}/name`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({ name: newName })
      });
      if (response.ok) {
        const updatedUser = await response.json();
        setUser(updatedUser);
      } else {
        console.error('Failed to update profile:', response.statusText);
      }
    } catch (error) {
      console.error('Error updating profile:', error);
    }
  };

  const handleDeleteAccount = async () => {
    const confirmDelete = window.confirm('Are you sure you want to delete your account?');
    if (confirmDelete) {
      try {
        const response = await fetch('http://127.0.0.1:8000/api/user', {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (response.ok) {
          alert('Account deleted successfully');
          // You may want to redirect the user to the login page or perform additional cleanup
        } else {
          console.error('Failed to delete account:', response.statusText);
        }
      } catch (error) {
        console.error('Error deleting account:', error);
      }
    }
  };

  const handleFileChange = (event: ChangeEvent<HTMLInputElement>) => {
    if (event.target.files && event.target.files.length > 0) {
      setSelectedFile(event.target.files[0]);
      handleUpdateProfilePicture(event.target.files[0]);
    }
  };

  const handleUpdateProfilePicture = async (file: File) => {
    const formData = new FormData();
    formData.append('profile_picture', file);

    try {
      const response = await fetch('http://127.0.0.1:8000/api/user/profile-picture', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: formData
      });
      if (response.ok) {
        const updatedUser = await response.json();
        setUser(updatedUser.user); // Assuming the response contains the updated user object
        alert('Profile picture updated successfully');
      } else {
        console.error('Failed to update profile picture:', response.statusText);
      }
    } catch (error) {
      console.error('Error updating profile picture:', error);
    }
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonBackButton defaultHref="/home" style={{ color: '#97FB57' }} />
          </IonButtons>
          <h1 style={{ textAlign: 'center', color: '#97FB57' }}>PROFILE</h1>
        </IonToolbar>
      </IonHeader>
      <IonContent>
        {user ? (
          <div style={{ padding: '20px', textAlign: 'center' }}>
            <div style={{ position: 'relative', marginBottom: '20px' }}>
              {user.profile_picture ? (
                <img 
                  src={`http://127.0.0.1:8000/storage/${user.profile_picture}`} 
                  alt="Profile" 
                  style={{ width: '150px', height: '150px', borderRadius: '50%', objectFit: 'cover' }} 
                />
              ) : (
                <p>No profile picture available</p>
              )}
              <div 
                style={{
                  position: 'absolute',
                  bottom: '3px',
                  right: '90px',
                  backgroundColor: '#97FB57',
                  borderRadius: '50%',
                  padding: '10px',
                  cursor: 'pointer',
                }}
                onClick={() => fileInputRef.current?.click()}
              >
                <FaCamera color="#121212" />
              </div>
            </div>
            <div style={{ marginBottom: '20px', color: '#97FB57' }}>
              <strong>Name:</strong> {user.name}
            </div>
            <div style={{ marginBottom: '20px', color: '#97FB57' }}>
              <strong>Email:</strong> {user.email}
            </div>
            <div style={{ marginBottom: '20px' }}>
              <MyButton text="Update" onClick={handleUpdateProfile} />
            </div>
            <div style={{ marginBottom: '20px' }}>
              <MyButton text="Delete" onClick={handleDeleteAccount} />
            </div>
            <input 
              type="file" 
              accept="image/*" 
              ref={fileInputRef} 
              style={{ display: 'none' }} 
              onChange={handleFileChange} 
            />
          </div>
        ) : (
          <div style={{ textAlign: 'center', padding: '20px' }}>Loading...</div>
        )}
      </IonContent>
    </IonPage>
  );
};

export default ProfilePage;
