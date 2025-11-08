import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { TherapistListPage } from './therapist-list.page';

const routes: Routes = [
  {
    path: '',
    component: TherapistListPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class TherapistListPageRoutingModule {}
