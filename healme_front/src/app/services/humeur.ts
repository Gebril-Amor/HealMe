import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Humeur {
  id: number;
  date: string;
  niveau: number;
  description: string;
  patient: number;
}

@Injectable({
  providedIn: 'root'
})
export class HumeurService {
  private apiUrl = 'http://127.0.0.1:8000/api/humeurs/';

  constructor(private http: HttpClient) {}

  getHumeurs(): Observable<Humeur[]> {
    return this.http.get<Humeur[]>(this.apiUrl);
  }

  addHumeur(humeur: Partial<Humeur>): Observable<Humeur> {
    return this.http.post<Humeur>(this.apiUrl, humeur);
  }
}
