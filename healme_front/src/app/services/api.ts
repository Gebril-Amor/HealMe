import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
@Injectable({
  providedIn: 'root'
})
export class ApiService {
   private baseUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  getHumeurs(userId: number): Observable<any> {
    return this.http.get(`${this.baseUrl}/users/${userId}/mood`);
  }

  getSommeils(userId: number): Observable<any> {
    return this.http.get(`${this.baseUrl}/users/${userId}/sleep`);
  }

  getJournal(userId: number): Observable<any> {
    return this.http.get(`${this.baseUrl}/users/${userId}/journal`);
  }
}

