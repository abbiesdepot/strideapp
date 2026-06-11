import SwiftUI

struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.strideSecondary.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "pills.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.strideSecondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.stridePrimary)
                Text(medication.dosage)
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(medication.scheduleTime)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.strideSecondary)
                Text(medication.frequency)
                    .font(.system(size: 12))
                    .foregroundColor(.strideTextSecondary)
            }
        }
        .padding(14)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
    }
}

struct ActivityRow: View {
    let activity: CareActivity

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.strideSecondary.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "figure.run")
                    .font(.system(size: 20))
                    .foregroundColor(.strideSecondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.stridePrimary)
                Text(activity.frequency)
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(activity.scheduleTime)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.strideSecondary)
            }
        }
        .padding(14)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
    }
}

struct ProfileStatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.strideSecondary)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.strideTextPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.strideTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct InfoTile: View {
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

struct NoteCard: View {
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
