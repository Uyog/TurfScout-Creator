import React, { useState } from 'react';
import axios from 'axios';
import { IonBackButton, IonButtons } from '@ionic/react';

const CreateTurfs: React.FC = () => {
  const [formData, setFormData] = useState({
    name: '',
    location: '',
    description: '',
    image: null as File | null,
    price: 0,
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      setFormData({ ...formData, image: e.target.files[0] });
    }
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    const postData = new FormData();
    postData.append('name', formData.name);
    postData.append('location', formData.location);
    postData.append('description', formData.description);
    if (formData.image) {
      postData.append('image', formData.image);
    }
    postData.append('price', formData.price.toString());

    try {
        const response = await axios.post('http://127.0.0.1:8000/api/turf', postData, {
          headers: {
            'Content-Type': 'multipart/form-data',
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          },
        });
        console.log('Turf created:', response.data);
        // Optionally, you can redirect or show a success message here
      } catch (error: any) {
        if (error.response) {
          // The request was made and the server responded with a status code that falls out of the range of 2xx
          console.error('Error creating turf:', error.response.data);
          console.error('Status:', error.response.status);
        } else if (error.request) {
          // The request was made but no response was received
          console.error('Error creating turf:', error.request);
        } else {
          // Something happened in setting up the request that triggered an Error
          console.error('Error creating turf:', error.message);
        }
        // Optionally, you can show an error message here
      }      
  };

  return (
    <div>
         <IonButtons slot="start">
            <IonBackButton defaultHref="/home" />
          </IonButtons>
      <h2>Create Turf</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label>Name:</label>
          <input type="text" name="name" value={formData.name} onChange={handleChange} required />
        </div>
        <div>
          <label>Location:</label>
          <input type="text" name="location" value={formData.location} onChange={handleChange} required />
        </div>
        <div>
          <label>Description:</label>
          <textarea name="description" value={formData.description} onChange={handleChange} required />
        </div>
        <div>
          <label>Image:</label>
          <input type="file" accept="image/*" onChange={handleImageChange} required />
        </div>
        <div>
          <label>Price:</label>
          <input type="number" name="price" value={formData.price} onChange={handleChange} required />
        </div>
        <button type="submit">Create Turf</button>
      </form>
    </div>
  );
};

export default CreateTurfs;
