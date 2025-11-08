import { Component, OnInit } from '@angular/core';
import { HumeurService, Humeur } from '../../services/humeur';

@Component({
  selector: 'app-humeurs',
  templateUrl: './humeurs.page.html',
  styleUrls: ['./humeurs.page.scss'],
  standalone: false,
})
export class HumeursPage implements OnInit {
  humeurs: Humeur[] = [];

  constructor(private humeurService: HumeurService) {}

  ngOnInit() {
    this.loadHumeurs();
  }

  loadHumeurs() {
    this.humeurService.getHumeurs().subscribe(data => {
      this.humeurs = data;
    });
  }
}
