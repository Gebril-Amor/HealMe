// src/app/services/auth.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, tap } from 'rxjs';
import { Preferences } from '@capacitor/preferences';
import { environment } from '../../environments/environment';
export interface User {
  id: number;
  username: string;
  email: string;
  user_type: string;
}

export interface AuthResponse {
  message: string;
  user: User;
  profile?: any;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  public currentUser$ = this.currentUserSubject.asObservable();
  private apiUrl = environment.apiUrl;


  constructor(private http: HttpClient) {
    this.loadStoredUser();
  }

  private async loadStoredUser() {
    try {
      const user = await Preferences.get({ key: 'currentUser' });
      if (user.value) {
        this.currentUserSubject.next(JSON.parse(user.value));
      }
    } catch (error) {
      console.error('Error loading stored user:', error);
    }
  }

 register(userData: any): Observable<AuthResponse> {
  console.log('Auth Service - Sending register request:', userData);
  return this.http.post<AuthResponse>(`${this.apiUrl}/register/`, userData).pipe(
    tap(async (response) => {
      console.log('Auth Service - Registration response:', response);
      await this.storeUserData(response.user);
      this.currentUserSubject.next(response.user);
    })
  );
}

  login(credentials: { email: string; password: string }): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/login/`, credentials, { 
      withCredentials: true 
    }).pipe(
      tap(async (response) => {
        await this.storeUserData(response.user);
        this.currentUserSubject.next(response.user);
      })
    );
  }

  logout(): Observable<any> {
    return this.http.post(`${this.apiUrl}/logout/`, {}, { 
      withCredentials: true 
    }).pipe(
      tap(async () => {
        await this.clearUserData();
        this.currentUserSubject.next(null);
      })
    );
  }

  private async storeUserData(user: User) {
    await Preferences.set({
      key: 'currentUser',
      value: JSON.stringify(user)
    });
  }

  private async clearUserData() {
    await Preferences.remove({ key: 'currentUser' });
  }

  getCurrentUser(): User | null {
    return this.currentUserSubject.value;
  }
}