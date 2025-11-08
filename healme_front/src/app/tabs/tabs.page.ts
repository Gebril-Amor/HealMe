import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-tabs',
  templateUrl: './tabs.page.html',
  styleUrls: ['./tabs.page.scss'],
  standalone: false
})
export class TabsPage implements OnInit {

  constructor() { }
 selectedTab = 'home';

  ngOnInit() {
  }

  onTabChange(event: any) {
  console.log('Selected tab:', event.tab);
  // event.tab is the tab="home", "insights", etc.
}

  selectTab(tab: string) {
    this.selectedTab = tab;
  }

}
