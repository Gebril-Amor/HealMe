import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { AlertController } from '@ionic/angular';
import { AuthService } from '../../services/auth';

@Component({
  selector: 'app-data-list',
  templateUrl: './data-list.page.html',
  styleUrls: ['./data-list.page.scss'],
  standalone: false
})
export class DataListPage implements OnInit {
  activeTab: string = 'mood';
  moods: any[] = [];
  sleepData: any[] = [];
  journalEntries: any[] = [];
  userId: number | null = null;
  isLoading: boolean = true;

  constructor(
    private http: HttpClient,
    private router: Router,
    private alertController: AlertController,
    private authService: AuthService
  ) {}

  async ngOnInit() {
    const currentUser = this.authService.getCurrentUser();
    this.userId = currentUser ? currentUser.id : null;
    await this.loadAllData();
  }

  ionViewDidEnter() {
  console.log('DataListPage: Page entered, reloading data...');
  const currentUser = this.authService.getCurrentUser();
  this.userId = currentUser ? currentUser.id : null;
  this.loadAllData();
}

  async loadAllData() {
    if (!this.userId) return;

    this.isLoading = true;
    try {
      // Load all data in parallel
      const [moods, sleep, journals] = await Promise.all([
        this.http.get(`http://127.0.0.1:8000/api/users/${this.userId}/mood/`).toPromise(),
        this.http.get(`http://127.0.0.1:8000/api/users/${this.userId}/sleep/`).toPromise(),
        this.http.get(`http://127.0.0.1:8000/api/users/${this.userId}/journal/`).toPromise()
      ]);

      this.moods = moods as any[] || [];
      this.sleepData = sleep as any[] || [];
      this.journalEntries = journals as any[] || [];
      
    } catch (error) {
      console.error('Error loading data:', error);
      this.moods = [];
      this.sleepData = [];
      this.journalEntries = [];
    } finally {
      this.isLoading = false;
    }
  }

  // Mood functions
  getMoodEmoji(niveau: number): string {
    if (niveau >= 9) return '😄';
    if (niveau >= 7) return '😊';
    if (niveau >= 5) return '😐';
    if (niveau >= 3) return '😔';
    return '😢';
  }

  getMoodColor(niveau: number): string {
    if (niveau >= 8) return 'success';
    if (niveau >= 6) return 'warning';
    return 'danger';
  }

  // Sleep functions
  getSleepEmoji(qualite: string): string {
    switch(qualite?.toLowerCase()) {
      case 'excellent': return '😴';
      case 'good': return '😊';
      case 'average': return '😐';
      case 'poor': return '😔';
      case 'very-poor': return '😫';
      default: return '🛌';
    }
  }

  // Journal functions
  truncateText(text: string, maxLength: number = 100): string {
    if (!text) return '';
    return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
  }

  // Delete functions
  async deleteMood(moodId: number) {
    await this.deleteItem('mood', moodId, () => {
      this.moods = this.moods.filter(mood => mood.id !== moodId);
    });
  }

  async viewJournalDetail(journal: any) {
  const alert = await this.alertController.create({
    header: `Journal Entry - ${this.formatDate(journal.date)}`,
    message: journal.contenu,
    buttons: ['OK']
  });
  await alert.present();
}

  async deleteSleep(sleepId: number) {
    await this.deleteItem('sleep', sleepId, () => {
      this.sleepData = this.sleepData.filter(sleep => sleep.id !== sleepId);
    });
  }

  async deleteJournal(journalId: number) {
    await this.deleteItem('journal', journalId, () => {
      this.journalEntries = this.journalEntries.filter(journal => journal.id !== journalId);
    });
  }

  private async deleteItem(type: 'mood' | 'sleep' | 'journal', id: number, onSuccess: () => void) {
  const typeNames = {
    mood: 'mood entry',
    sleep: 'sleep data', 
    journal: 'journal entry'
  };

  const alert = await this.alertController.create({
    header: 'Confirm Delete',
    message: `Are you sure you want to delete this ${typeNames[type]}?`,
    buttons: [
      {
        text: 'Cancel',
        role: 'cancel'
      },
      {
        text: 'Delete',
        handler: async () => {
          try {
            const endpoint = type === 'mood' ? 'humeurs' : type === 'sleep' ? 'sommeils' : 'journaux';
            await this.http.delete(`http://127.0.0.1:8000/api/${endpoint}/${id}/`).toPromise();
            onSuccess();
          } catch (error) {
            this.showError(`Failed to delete ${typeNames[type]}`);
          }
        }
      }
    ]
  });
  await alert.present();
}

  // Navigation
  goToAddData() {
    this.router.navigate(['tabs/add']);
  }

  setActiveTab(event: any) {
    if (typeof event === 'string') {
      this.activeTab = event;
    } else if (event.detail && event.detail.value) {
      this.activeTab = event.detail.value;
    }
  }

  formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  }

  private async showError(message: string) {
    const alert = await this.alertController.create({
      header: 'Error',
      message: message,
      buttons: ['OK']
    });
    await alert.present();
  }
}