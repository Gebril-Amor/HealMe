import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { TabsPage } from './tabs.page';

const routes: Routes = [
  {
    path: '',
    component: TabsPage,
    children: [
      { path: 'home', loadChildren: () => import('../home/home.module').then(m => m.HomePageModule) },
      { path: 'add', loadChildren: () =>  import('../pages/add-data/add-data.module').then(m => m.AddDataPageModule) },
      { path: 'list', loadChildren: () =>  import('../pages/data-list/data-list.module').then(m => m.DataListPageModule) },
      { path: 'therapist-list', loadChildren: () =>  import('../pages/therapist-list/therapist-list.module').then(m => m.TherapistListPageModule) },
     
      { path: '', redirectTo: 'home', pathMatch: 'full' }
    ]
  }
];


@NgModule({
  imports: [RouterModule.forChild(routes)],
})
export class TabsPageRoutingModule {}

