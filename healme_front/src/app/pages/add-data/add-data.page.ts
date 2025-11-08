// add-data.page.ts
import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { AlertController } from '@ionic/angular';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-add-data',
  templateUrl: './add-data.page.html',
  styleUrls: ['./add-data.page.scss'],
  standalone: false
})
export class AddDataPage {
  // User ID - you can get this from your auth service or storage
  userId: number | null = null;
  
  // Mood data
  moodData = {
    patient: this.userId,
    date: new Date().toISOString().split('T')[0],
    niveau: 5,
    description: ''
  };

  // Sleep data
  sleepData = {
    patient: this.userId,
    date: new Date().toISOString().split('T')[0],
    dureeHeures: 7,
    qualite: 'good'
  };

  // Journal data
  journalData = {
    patient: this.userId,
    date: new Date().toISOString().split('T')[0],
    contenu: ''
  };

  qualityOptions = [
    { value: 'excellent', label: 'Excellent' },
    { value: 'good', label: 'Good' },
    { value: 'average', label: 'Average' },
    { value: 'poor', label: 'Poor' },
    { value: 'very-poor', label: 'Very Poor' }
  ];

  activeTab: string = 'mood';

  constructor(
    private http: HttpClient,
    private router: Router,
    private alertController: AlertController,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    const currentUser = this.authService.getCurrentUser();
    this.userId = currentUser ? currentUser.id : null;
    // Update the patient fields with the actual user ID
    this.updatePatientIds();
  }

  // Update all patient IDs with the current user ID
  private updatePatientIds() {
    if (this.userId) {
      this.moodData.patient = this.userId;
      this.sleepData.patient = this.userId;
      this.journalData.patient = this.userId;
    }
  }

  // Add Mood
  async addMood() {
    if (!this.userId) {
      this.showError('User not authenticated');
      return;
    }

    try {
      await this.http.post('http://127.0.0.1:8000/api/humeurs/', this.moodData).toPromise();
      this.showSuccess('Mood added successfully!');
      this.resetMoodForm();
    } catch (error) {
      this.showError('Failed to add mood entry');
    }
  }

  // Add Sleep
  async addSleep() {
    if (!this.userId) {
      this.showError('User not authenticated');
      return;
    }

    try {
      await this.http.post('http://127.0.0.1:8000/api/sommeils/', this.sleepData).toPromise();
      this.showSuccess('Sleep data added successfully!');
      this.resetSleepForm();
    } catch (error) {
      this.showError('Failed to add sleep data');
    }
  }

  // Add Journal
  async addJournal() {
    if (!this.userId) {
      this.showError('User not authenticated');
      return;
    }

    try {
      await this.http.post('http://127.0.0.1:8000/api/journaux/', this.journalData).toPromise();
      this.showSuccess('Journal entry added successfully!');
      this.resetJournalForm();
    } catch (error) {
      this.showError('Failed to add journal entry');
    }
  }

  // Helper methods
  private async showSuccess(message: string) {
    const alert = await this.alertController.create({
      header: 'Success',
      message: message,
      buttons: ['OK']
    });
    await alert.present();
  }

  private async showError(message: string) {
    const alert = await this.alertController.create({
      header: 'Error',
      message: message,
      buttons: ['OK']
    });
    await alert.present();
  }

  private resetMoodForm() {
    this.moodData = {
      patient: this.userId,
      date: new Date().toISOString().split('T')[0],
      niveau: 5,
      description: ''
    };
  }

  private resetSleepForm() {
    this.sleepData = {
      patient: this.userId,
      date: new Date().toISOString().split('T')[0],
      dureeHeures: 7,
      qualite: 'good'
    };
  }

  private resetJournalForm() {
    this.journalData = {
      patient: this.userId,
      date: new Date().toISOString().split('T')[0],
      contenu: ''
    };
  }

  // Fix: Handle the segment change event properly
  setActiveTab(event: any) {
    // Handle both string and event object
    if (typeof event === 'string') {
      this.activeTab = event;
    } else if (event.detail && event.detail.value) {
      this.activeTab = event.detail.value;
    }
  }
}