import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Slider from 'react-slick';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonBackButton,
  IonButtons,
  IonInfiniteScroll,
  IonInfiniteScrollContent,
  IonModal,
  IonButton,
  IonInput,
  IonItem,
  IonLabel,
  IonTextarea,
  IonCard,
  IonCardContent,
} from '@ionic/react';

import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import '../pages/View-turfs.css';
import MyButton from '../components/Button';

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
  const [page, setPage] = useState<number>(1);
  const [hasMore, setHasMore] = useState<boolean>(true);
  const [showUpdateModal, setShowUpdateModal] = useState<boolean>(false);
  const [selectedTurf, setSelectedTurf] = useState<Turf | null>(null);
  const [updateData, setUpdateData] = useState<Partial<Turf>>({});

  useEffect(() => {
    const fetchTurfs = async () => {
      try {
        const response = await axios.get(`http://127.0.0.1:8000/api/turf?page=${page}`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          },
        });
        if (response.data.length === 0) {
          setHasMore(false);
          return;
        }
        setTurfs((prevTurfs) => [...prevTurfs, ...response.data]);
      } catch (error) {
        console.error('Error fetching turfs:', error);
      }
    };

    fetchTurfs();
  }, [page]);

  const loadMore = (e: CustomEvent<void>) => {
    setPage((prevPage) => prevPage + 1);
    (e.target as HTMLIonInfiniteScrollElement).complete();
  };

  const settings = {
    dots: false,
    infinite: true,
    vertical: true,
    verticalSwiping: true,
    speed: 6000,
    slidesToShow: 3,
    slidesToScroll: 1,
    autoplay: true,
    autoplaySpeed: 0,
    cssEase: "linear",
    centerMode: true,
    focusOnSelect: true,
    variableWidth: true,
  };

  const handleUpdate = (turf: Turf) => {
    setSelectedTurf(turf);
    setUpdateData({
      name: turf.name,
      location: turf.location,
      description: turf.description,
      price: turf.price,
    });
    setShowUpdateModal(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Are you sure you want to delete this turf?')) {
      try {
        await axios.delete(`http://127.0.0.1:8000/api/turf/${id}`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          },
        });
        setTurfs(turfs.filter((turf) => turf.id !== id));
      } catch (error) {
        console.error('Error deleting turf:', error);
      }
    }
  };

  const handleUpdateChange = (e: CustomEvent) => {
    const target = e.target as HTMLInputElement | HTMLTextAreaElement;
    const { name, value } = target;
    setUpdateData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  const handleUpdateSubmit = async () => {
    if (!selectedTurf) return;
    try {
      await axios.put(`http://127.0.0.1:8000/api/turf/${selectedTurf.id}`, updateData, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });
      setTurfs(
        turfs.map((turf) =>
          turf.id === selectedTurf.id ? { ...turf, ...updateData } : turf
        )
      );
      setShowUpdateModal(false);
    } catch (error) {
      console.error('Error updating turf:', error);
    }
  };

  const handleImageError = (event: React.SyntheticEvent<HTMLImageElement, Event>) => {
    console.error('Error loading image', event);
    (event.target as HTMLImageElement).src = '/assets/default-image.jpg';
  };

  return (
    <>
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonBackButton defaultHref="/home" />
          </IonButtons>
          <IonTitle>Your Turfs</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        <div className="slider-container">
          <Slider {...settings}>
            {turfs.map((turf) => (
              <div key={turf.id} className="slide-card">
                <IonCard>
                  <img
                    src={`http://127.0.0.1:8000${turf.image_url}`}
                    onError={handleImageError}
                    alt={turf.name}
                    style={{ width: '100%', height: 'auto' }}
                  />
                  <IonCardContent>
                    <IonLabel>
                      <h2>{turf.name}</h2>
                      <p>{turf.location}</p>
                      <p className="price">kshs {turf.price}</p>
                      <p>{turf.description}</p>
                    </IonLabel>
                    <div className="button-container">
                      <MyButton text="Update" onClick={() => handleUpdate(turf)} />
                      <MyButton text="Delete" onClick={() => handleDelete(turf.id)} />
                    </div>
                  </IonCardContent>
                </IonCard>
              </div>
            ))}
          </Slider>
        </div>
        <IonInfiniteScroll threshold="100px" disabled={!hasMore} onIonInfinite={loadMore}>
          <IonInfiniteScrollContent loadingText="Loading more turfs..." loadingSpinner="dots" />
        </IonInfiniteScroll>

        <IonModal isOpen={showUpdateModal} onDidDismiss={() => setShowUpdateModal(false)}>
          <IonHeader>
            <IonToolbar>
              <IonTitle>Update Turf</IonTitle>
            </IonToolbar>
          </IonHeader>
          <IonContent className="ion-padding">
            <IonItem>
              <IonLabel position="stacked">Name</IonLabel>
              <IonInput
                name="name"
                value={updateData.name}
                onIonChange={(e) => handleUpdateChange(e as CustomEvent)}
              />
            </IonItem>
            <IonItem>
              <IonLabel position="stacked">Location</IonLabel>
              <IonInput
                name="location"
                value={updateData.location}
                onIonChange={(e) => handleUpdateChange(e as CustomEvent)}
              />
            </IonItem>
            <IonItem>
              <IonLabel position="stacked">Description</IonLabel>
              <IonTextarea
                name="description"
                value={updateData.description}
                onIonChange={(e) => handleUpdateChange(e as CustomEvent)}
              />
            </IonItem>
            <IonItem>
              <IonLabel position="stacked">Price</IonLabel>
              <IonInput
                name="price"
                type="number"
                value={updateData.price}
                onIonChange={(e) => handleUpdateChange(e as CustomEvent)}
              />
            </IonItem>
            <IonButton expand="block" onClick={handleUpdateSubmit}>
              Save
            </IonButton>
            <IonButton expand="block" color="light" onClick={() => setShowUpdateModal(false)}>
              Cancel
            </IonButton>
          </IonContent>
        </IonModal>
      </IonContent>
    </>
  );
};

export default ViewTurfs;
