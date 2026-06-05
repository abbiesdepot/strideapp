import SwiftUI

struct ElderlyDetailView: View {
    var profile: ElderlyProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // FOTO & INFO UTAMA
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.strideTertiary.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.stridePrimary)
                        )

                    Text(profile.fullName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.stridePrimary)

                    Text("\(profile.age) Years Old")
                        .font(.system(size: 16))
                        .foregroundColor(.strideTextSecondary)

                    LiveStatusBadge(status: profile.liveStatus)
                }
                .padding(.top, 24)

                // STATS ROW
                HStack {
                    StatItem(icon: "figure.walk", value: "\(profile.stepCount)", label: "Steps today")
                    Spacer()
                    StatItem(icon: "map", value: String(format: "%.1f km", profile.distanceKM), label: "Distance")
                    Spacer()
                    StatItem(icon: "heart.fill", value: "72 bpm", label: "Heart Rate")
                }
                .padding(20)
                .background(Color.strideCardWhite)
                .cornerRadius(StrideTheme.cornerRadiusCard)
                .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
                .padding(.horizontal, 24)

                // PHYSICAL INFO
                VStack(alignment: .leading, spacing: 16) {
                    Text("Physical Information")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.stridePrimary)

                    HStack(spacing: 12) {
                        // Height
                        InfoTile(
                            icon: "ruler",
                            iconColor: .strideSecondary,
                            label: "Height",
                            value: profile.height != nil ? String(format: "%.0f cm", profile.height!) : "—"
                        )

                        // Weight
                        InfoTile(
                            icon: "scalemass",
                            iconColor: .strideSecondary,
                            label: "Weight",
                            value: profile.weight != nil ? String(format: "%.0f kg", profile.weight!) : "—"
                        )

                        // Blood Type
                        InfoTile(
                            icon: "drop.fill",
                            iconColor: .strideRed,
                            label: "Blood Type",
                            value: profile.bloodType ?? "—"
                        )
                    }
                }
                .padding(.horizontal, 24)

                // MEDICAL NOTES
                if let medicalNotes = profile.medicalNotes, !medicalNotes.isEmpty {
                    NoteCard(
                        icon: "heart.text.square",
                        iconColor: .strideRed,
                        title: "Medical Notes",
                        content: medicalNotes
                    )
                    .padding(.horizontal, 24)
                }

                // GENERAL NOTES
                if let notes = profile.notes, !notes.isEmpty {
                    NoteCard(
                        icon: "note.text",
                        iconColor: .strideSecondary,
                        title: "General Notes",
                        content: notes
                    )
                    .padding(.horizontal, 24)
                }

                // STATUS REASON
                if !profile.liveStatusReason.isEmpty {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.strideSecondary)
                        Text(profile.liveStatusReason)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.strideTextPrimary)
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.strideSecondary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 16)
            }
        }
        .background(Color.strideBackground.ignoresSafeArea())
        .navigationTitle("Profile Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views

private struct InfoTile: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.strideTextPrimary)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.strideTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
    }
}

private struct NoteCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.strideTextPrimary)
                Spacer()
            }

            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.strideTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
    }
}
