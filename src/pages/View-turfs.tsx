import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { IonHeader, IonToolbar, IonTitle, IonContent, IonBackButton, IonButtons, IonList, IonItem, IonLabel, IonGrid, IonRow, IonCol, IonInfiniteScroll, IonInfiniteScrollContent } from '@ionic/react';

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
        setTurfs([...turfs, ...response.data]);
      } catch (error) {
        console.error('Error fetching turfs:', error);
      }
    };

    fetchTurfs();
  }, [page]); // Fetch turfs whenever the page changes

  const loadMore = () => {
    setPage(page + 1); // Increment the page number to fetch the next page of turfs
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
      <IonContent>
        <IonList>
          {turfs.map((turf, index) => (
            <IonItem key={index}>
              <IonLabel>
                <h2>{turf.name}</h2>
                <p>{turf.location}</p>
              </IonLabel>
              <IonGrid>
                <IonRow>
                  <IonCol size="12" size-sm="8" size-md="8" size-lg="8" size-xl="8" className="ion-text-end">
                    <p>kshs {turf.price}</p>
                  </IonCol>
                </IonRow>
              </IonGrid>
            </IonItem>
          ))}
        </IonList>
        <IonInfiniteScroll threshold="100px" disabled={!hasMore} onIonInfinite={loadMore}>
          <IonInfiniteScrollContent
            loadingText="Loading more turfs..."
            loadingSpinner="dots"
          />
        </IonInfiniteScroll>
      </IonContent>
    </>
  );
};

export default ViewTurfs;
