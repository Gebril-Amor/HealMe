import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TherapistListPage } from './therapist-list.page';

describe('TherapistListPage', () => {
  let component: TherapistListPage;
  let fixture: ComponentFixture<TherapistListPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(TherapistListPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
