//
//  MiniUserProfileView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/5/22.
//

import SwiftUI
import DiscordKit
import CachedAsyncImage

struct MiniUserProfileView: View {
	let user: User
	let profile: UserProfile?
	let guildRoles: [Role]?
	let guildID: Snowflake?
	let isWebhook: Bool
	let loadError: Bool
	let hideNotes: Bool

	@State private var note = ""

    var body: some View {
		let avatarURL = user.avatarURL()

		VStack(alignment: .leading, spacing: 0) {
			if let accentColor = profile?.user.accent_color ?? user.accent_color {
				Rectangle().fill(Color(hex: accentColor))
					.frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
					.clipShape(ProfileAccentMask(insetStart: 14, insetWidth: 92))
			} else {
				CachedAsyncImage(url: avatarURL) { image in
					image.resizable().scaledToFill()
				} placeholder: { ProgressView().progressViewStyle(.circular)}
					.frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
					.blur(radius: 4)
					.clipped()
					.clipShape(ProfileAccentMask(insetStart: 14, insetWidth: 92))
			}
			HStack(alignment: .bottom, spacing: 4) {
				CachedAsyncImage(url: avatarURL) { image in
					image.resizable().scaledToFill()
				} placeholder: {
					ProgressView().progressViewStyle(.circular)
				}
				.clipShape(Circle())
				.frame(width: 80, height: 80)
				.padding(6)

				if let fullUser = profile?.user {
					ProfileBadges(user: fullUser)
						.frame(minHeight: 40, alignment: .topLeading)
				}
			}
			.padding(.leading, 14)
			.padding(.top, -46) // 92/2 = 46

			VStack(alignment: .leading, spacing: 8) {
				HStack(alignment: .center, spacing: 6) {
					Group {
						Text(user.username).fontWeight(.bold)
						// Webhooks don't have discriminators
						+ Text(isWebhook ? "" : "#\(user.discriminator)")
							.foregroundColor(.primary.opacity(0.7))
					}.font(.title2).lineLimit(1)
					if user.bot == true || isWebhook {
						NonUserBadge(flags: user.public_flags, isWebhook: isWebhook)
					}

					Spacer()
					if loadError {
						Image(systemName: "exclamationmark.triangle.fill")
							.font(.system(size: 20))
							.foregroundColor(.orange)
							.help("Failed to get full user profile")
					}
				}
				.padding(.bottom, -2)
				.padding(.top, -8)

				Divider().padding(.vertical, 8)

				if isWebhook {
					Text("This user is a webhook")
					Button {

					} label: {
						Label("Manage Server Webhooks", systemImage: "link")
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(.borderedProminent)
					.controlSize(.large)
				} else {
					if profile == nil, !loadError {
						ProgressView("Loading full profile...")
							.progressViewStyle(.linear)
							.frame(maxWidth: .infinity)
							.tint(.blue)
					}

					if let bio = profile?.user.bio, !bio.isEmpty {
						Text("ABOUT ME").font(.headline)
						Text(bio)
							.fixedSize(horizontal: false, vertical: true)
							.padding(.bottom, 8)
					}

					if let profile = profile, guildID != "@me" {
						if let guildRoles = guildRoles {
							let roles = guildRoles.filter {
								profile.guild_member?.roles.contains($0.id) ?? false
							}

							Text(profile.guild_member == nil ? "LOADING ROLES"
								 : (roles.isEmpty
									? "NO ROLES"
									: (roles.count == 1 ? "ROLE" : "ROLES")
								   )
							).font(.headline)
							if !roles.isEmpty {
								TagCloudView(content: roles.map({ role in
									HStack(spacing: 6) {
										Circle()
											.fill(Color(hex: role.color))
											.frame(width: 14, height: 14)
											.padding(.leading, 6)
										Text(role.name)
											.font(.system(size: 12))
											.padding(.trailing, 8)
									}
									.frame(height: 24)
									.background(Color.gray.opacity(0.2))
									.cornerRadius(7)
								})).padding(-2)
							}
						} else {
							ProgressView("Loading roles...")
								.progressViewStyle(.linear)
								.frame(maxWidth: .infinity)
								.tint(.blue)
						}
					}

					if !hideNotes {
						Text("NOTE").font(.headline).padding(.top, 8)
						 // Notes are stored locally for now, but eventually will be synced with the Discord API
						 TextField("Add a note to this user (only visible to you)", text: $note)
							 .textFieldStyle(.roundedBorder)
							 .onChange(of: note) { _ in
								 if note.isEmpty {
									 UserDefaults.standard.removeObject(forKey: "notes.\(user.id)")
								 } else {
									 UserDefaults.standard.set(note, forKey: "notes.\(user.id)")
								 }
							 }
							 .onAppear {
								 note = UserDefaults.standard.string(forKey: "notes.\(user.id)") ?? ""
							 }
					}
				}
			}
			.padding(14)
		}
		.frame(width: 300)
	}
}

struct MiniUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        /*MiniUserProfileView()*/
		EmptyView()
    }
}
