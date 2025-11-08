import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { ApiService } from '../services/api';
import { Chart, ChartConfiguration, LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Legend } from 'chart.js';
import { AuthService } from '../services/auth';
import { Router } from '@angular/router';

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Legend);

@Component({
  selector: 'app-home',
  templateUrl: './home.page.html',
  styleUrls: ['./home.page.scss'],
  standalone: false
})
export class HomePage implements OnInit, AfterViewInit {
  @ViewChild('sleepCanvas') sleepCanvas!: ElementRef<HTMLCanvasElement>;
  sleepChart!: Chart;
  userId: number | null = null;
  userName: string = 'Guest';
  humeurs: any[] = [];
  sommeils: any[] = [];
  journal: any = null;

  constructor(private api: ApiService, private authService: AuthService,private router: Router) {}

  ngOnInit() {
    this.loadUserAndData();
  }

  ngAfterViewInit() {
    // Chart will be created in updateSleepChart after data loads
  }
logout() {
  this.router.navigate(['/login']);
}
  loadUserAndData() {
    const currentUser = this.authService.getCurrentUser();
    this.userName = currentUser ? currentUser.username : 'Guest';
    this.userId = currentUser ? currentUser.id : null;
    
    // Only load data if we have a user ID
    if (this.userId) {
      this.loadData();
    } else {
      console.log('No user ID available');
    }
  }

  ionViewWillEnter() {
    this.loadUserAndData();
  }

  loadData() {
    if (!this.userId) {
      console.error('Cannot load data: user ID is null');
      return;
    }

    this.api.getHumeurs(this.userId).subscribe(data => {
      this.humeurs = data;
      this.humeurs.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    });
    
    this.api.getSommeils(this.userId).subscribe(data => {
      this.sommeils = data;
      this.sommeils.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
      this.updateSleepChart(); // update chart after data is loaded
    });
    
    this.api.getJournal(this.userId).subscribe(data => {
      this.journal = data[0] || null;
    });
  }
  // Recent moods (last 5 days)
  get recentHumeurs() {
    return this.humeurs.slice(0, 5);
  }

  // Recent sleep data (last 5 days)
  get recentSommeils() {
    return this.sommeils.slice(0, 5);
  }

  // ---- Sleep Chart ----
  updateSleepChart() {
    if (!this.sleepCanvas) return;
    
    const labels = this.recentSommeils.slice().reverse()
      .map(s => new Date(s.date).toLocaleDateString('en-US', { weekday: 'short' }));
    const data = this.recentSommeils.slice().reverse()
      .map(s => s.dureeHeures);

    const config: ChartConfiguration = {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          data: data,
          borderColor: 'rgba(100, 200, 255, 0.8)',
          backgroundColor: 'rgba(100, 200, 255, 0.2)',
          tension: 0.4,
          fill: true,
          pointRadius: 5,
          pointBackgroundColor: 'rgba(100, 200, 255, 1)'
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: function(context) {
                return context.raw + ' hours';
              }
            }
          }
        },
        scales: {
          y: {
            min: 0,
            max: 12,
            ticks: {
              stepSize: 1,
              callback: function(value) {
                return value + 'h';
              }
            },
            title: { display: true, text: 'Hours of Sleep' }
          },
          x: {
            title: { display: true, text: 'Days' }
          }
        }
      }
    };

    if (this.sleepChart) {
      this.sleepChart.destroy(); // destroy previous chart if exists
    }

    this.sleepChart = new Chart(this.sleepCanvas.nativeElement.getContext('2d')!, config);
  }

  // ---- Mood / Sleep / Journal Helpers ----
  getMoodEmoji(niveau: number): string {
    switch(niveau) {
      case 1: return '😢';
      case 2: return '😐';
      case 3: return '😊';
      case 4: return '🤩';
      case 5: return '😴';
      default: return '😐';
    }
  }

  getMoodEmojiClass(niveau: number): string {
    return `mood-${niveau}`;
  }

  getSleepPercentage(dureeHeures: number): number {
    const maxHours = 10;
    return Math.min((dureeHeures / maxHours) * 100, 100);
  }

  getMoodInsight(): string {
    if (this.humeurs.length === 0) return 'Track your mood to get insights';
    const avgMood = this.humeurs.reduce((sum, h) => sum + h.niveau, 0) / this.humeurs.length;
    if (avgMood >= 4) return 'AI Insight: You maintain excellent mood levels consistently!';
    if (avgMood >= 3) return 'AI Insight: Your mood is generally positive with good stability.';
    if (avgMood >= 2) return 'AI Insight: Your mood shows some fluctuations. Consider tracking triggers.';
    return 'AI Insight: Your mood patterns suggest you might benefit from additional support.';
  }

  getSleepInsight(): string {
    if (this.sommeils.length === 0) return 'Track your sleep to get insights';
    const avgSleep = this.sommeils.reduce((sum, s) => sum + s.dureeHeures, 0) / this.sommeils.length;
    const avgQuality = this.sommeils.filter(s => s.qualite === 'good' || s.qualite === 'excellent').length / this.sommeils.length;
    if (avgSleep >= 7 && avgQuality > 0.7) return 'AI Insight: Excellent sleep duration and quality!';
    if (avgSleep >= 6 && avgQuality > 0.5) return 'AI Insight: Good sleep patterns with room for improvement.';
    return 'AI Insight: Your sleep patterns could benefit from more consistency.';
  }

  getJournalPreview(): string {
    if (!this.journal) return '';
    return this.journal.contenu.length > 150 ? this.journal.contenu.substring(0, 150) + '...' : this.journal.contenu;
  }

  getJournalInsight(): string {
    if (!this.journal) return 'Start journaling to get insights';
    const content = this.journal.contenu.toLowerCase();
    let insight = 'AI Insight: ';
    if (content.includes('anxious') || content.includes('stress')) {
      insight += 'Your entry mentions anxiety. Consider mindfulness techniques.';
    } else if (content.includes('happy') || content.includes('grateful')) {
      insight += 'Positive reflections detected! This mindset supports wellbeing.';
    } else if (content.includes('tired') || content.includes('exhaust')) {
      insight += 'Fatigue mentioned. Monitor sleep and energy patterns.';
    } else {
      insight += 'Regular journaling helps build self-awareness and emotional intelligence.';
    }
    return insight;
  }

  readMore() {
    console.log('Navigate to full journal entry');
  }
}
