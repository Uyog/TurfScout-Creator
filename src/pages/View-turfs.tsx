import React, { useState, useEffect } from 'react';
import axios from 'axios';

interface Turf {
  id: number;
  name: string;
  location: string;
  description: string;
  image_url: string;
  price: number;
}

const ViewTurfs: React.FC = () => {
  const [turfs, setTurfs] = useState<Turf[]>([]);

  useEffect(() => {
    const fetchTurfs = async () => {
      try {
        const response = await axios.get('http://127.0.0.1:8000/api/turf');
        setTurfs(response.data);
      } catch (error) {
        console.error('Error fetching turfs:', error);
      }
    };

    fetchTurfs();
  }, []);

  return (
    <div>
      <h1>Your Turfs</h1>
      {turfs.map((turf) => (
        <div key={turf.id}>
          <h2>{turf.name}</h2>
          <p>{turf.location}</p>
          <p>{turf.description}</p>
          <p>Price: ${turf.price}</p>
          <img src={turf.image_url} alt={turf.name} style={{ maxWidth: '200px' }} />
          {/* Add more details or actions as needed */}
        </div>
      ))}
    </div>
  );
};

export default ViewTurfs;
